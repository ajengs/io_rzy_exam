defmodule IoRzyExamWeb.AccountController do
  use IoRzyExamWeb, :controller
  require Logger

  alias IoRzyExam.{Accounts, Failures}
  alias IoRzyExam.Accounts.Account
  alias IoRzyExam.Client.{Razoyo, Words}

  def index(conn, _params) do
    accounts = Accounts.source_accounts() |> Accounts.list_accounts()

    render(conn, :index, accounts: accounts)
  end

  def edit(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    check_failures()
    |> check_secret(account)
    |> show_edit(conn, account)
  end

  def update(conn, %{"id" => id, "account" => account_params} = params) do
    account = Accounts.get_account!(id)
    changeset = Account.changeset(account, account_params)

    if !changeset.valid? do
      render(conn, :edit, account: account, changeset: %{changeset | action: :update})
    else
      check_failures()
      |> check_secret(account)
      |> process_update(conn, params, account)
    end
  end

  def transfer(conn, _) do
    accounts = Accounts.authorized_accounts() |> Accounts.list_accounts()

    if Enum.count(accounts) == 0 do
      conn
      |> put_flash(:error, "No authorized accounts found!")
      |> redirect(to: ~p"/accounts")
    else
      process_transfer(conn, accounts)
    end
  end

  defp process_update({:error, message}, conn, _, _) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: ~p"/accounts")
  end

  defp process_update(:ok, conn, %{"account" => %{"secret" => secret} = account_params}, account) do
    with {:ok, _} <- Words.get_word(secret),
         {:ok, auth} <- authorize_account(account_params, account),
         {:ok, _account} <- update_account(account, account_params, auth) do
      conn
      |> put_flash(:info, "account updated successfully.")
      |> redirect(to: ~p"/accounts")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.debug(inspect(changeset))
        render(conn, :edit, account: account, changeset: changeset)

      {:error, error} ->
        changeset =
          account
          |> Account.changeset(account_params)
          |> Ecto.Changeset.add_error(:secret, error)

        render(conn, :edit,
          account: account,
          changeset: %{changeset | action: :update}
        )
    end
  end

  defp update_account(account, account_params, auth) do
    update_params =
      account_params
      |> Map.put("secret", Map.get(auth, "token"))
      |> Map.put("amount", Map.get(auth, "amount"))

    Accounts.update_account(account, update_params)
  end

  defp process_transfer(conn, accounts) do
    total =
      accounts
      |> Enum.reduce(Decimal.new(0), fn a, total -> Decimal.add(total, a.amount) end)
      |> Decimal.to_float()

    req_body = %{
      "type" => "Transfer",
      "authorizations" => Enum.map(accounts, fn a -> a.secret end),
      "total" => total
    }

    access_token = Enum.at(accounts, 0).access_token

    with {:ok, res} <- IoRzyExam.Client.Razoyo.post_operations(req_body, access_token) do
      Logger.debug(inspect(res))
      update_transfer_flag(accounts)

      conn
      |> put_flash(:info, "Funds transferred successfully! $#{Map.get(res, "total")}")
      |> redirect(to: ~p"/accounts")
    else
      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: ~p"/accounts")
    end
  end

  defp show_edit({:error, message}, conn, _) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: ~p"/accounts")
  end

  defp show_edit(:ok, conn, account) do
    changeset = Accounts.change_account(account)
    render(conn, :edit, account: account, changeset: changeset)
  end

  defp authorize_account(account_params, account) do
    req_body = %{
      "type" => "Authorize",
      "routing" => account.routing,
      "account" => account.account,
      "secret" => Map.get(account_params, "secret")
    }

    case Razoyo.post_operations(req_body, account.access_token) do
      {:error, error} ->
        Failures.create_failure(%{"account" => account.account})
        {:error, error}

      res ->
        res
    end
  end

  defp check_secret(:ok, %_{secret: secret}) when is_nil(secret), do: :ok
  defp check_secret(:ok, _), do: {:error, "Account is already authorized!"}
  defp check_secret(error, _), do: error

  defp check_failures do
    failure = Failures.within_timeframe() |> Failures.list_failures() |> Enum.count()

    cond do
      failure > 3 -> {:error, "Too many authorization failures. Try again later."}
      true -> :ok
    end
  end

  defp update_transfer_flag(accounts) do
    Enum.each(accounts, fn account ->
      Accounts.update_account(account, %{transferred: true})
    end)
  end
end
