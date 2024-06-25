defmodule IoRzyExamWeb.AccountController do
  use IoRzyExamWeb, :controller
  require Logger

  alias IoRzyExam.Accounts
  alias IoRzyExam.Accounts.Account

  def index(conn, _params) do
    accounts = Accounts.list_accounts()

    render(conn, :index, accounts: accounts)
  end

  def edit(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    changeset = Accounts.change_account(account)
    render(conn, :edit, account: account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)
    req_body = Map.put(account_params, "type", "Authorize")

    if account.failure > 2 do
      conn
      |> put_flash(:error, "Too many authorization failures. Try again later.")
      |> redirect(to: ~p"/accounts")
    else
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
          Logger.error(inspect(error))

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
  end
end
