defmodule IoRzyExamWeb.AccountController do
  use IoRzyExamWeb, :controller
  require Logger

  alias IoRzyExam.{Accounts, Failures}
  alias IoRzyExam.Accounts.Account

  def index(conn, _params) do
    accounts = Accounts.list_accounts()

    render(conn, :index, accounts: accounts)
  end

  def edit(conn, params) do
    check_failures()
    |> show_edit(conn, params)
  end

  def update(conn, %{"id" => id, "account" => account_params} = params) do
    account = Accounts.get_account!(id)
    changeset = Account.changeset(account, account_params)

    if !changeset.valid? do
      render(conn, :edit, account: account, changeset: %{changeset | action: :update})
    else
      check_failures()
      |> process_update(conn, params, account)
    end
  end

  defp process_update({:error, message}, conn, _, _) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: ~p"/accounts")
  end

  defp process_update(:ok, conn, %{"account" => account_params}, account) do
    req_body = Map.put(account_params, "type", "Authorize")

    with {:ok, auth} <- IoRzyExam.Client.Razoyo.authorize(req_body, account.access_token) do
      update_params =
        account_params
        |> Map.put("secret", Map.get(auth, "token"))
        |> Map.put("amount", Map.get(auth, "amount"))

      case Accounts.update_account(account, update_params) do
        {:ok, _account} ->
          conn
          |> put_flash(:info, "account updated successfully.")
          |> redirect(to: ~p"/accounts")

        {:error, %Ecto.Changeset{} = changeset} ->
          Logger.debug(inspect(changeset))
          render(conn, :edit, account: account, changeset: changeset)
      end
    else
      {:error, error} ->
        Failures.create_failure(%{"account" => account.account})

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

  defp show_edit({:error, message}, conn, _) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: ~p"/accounts")
  end

  defp show_edit(:ok, conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    changeset = Accounts.change_account(account)
    render(conn, :edit, account: account, changeset: changeset)
  end

  defp check_failures do
    failure = Failures.list_failures_within_period() |> Enum.count()

    cond do
      failure > 3 -> {:error, "Too many authorization failures. Try again later."}
      true -> :ok
    end
  end
end
