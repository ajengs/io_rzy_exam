defmodule IoRzyExamWeb.TransactionController do
  use IoRzyExamWeb, :controller
  require Logger

  alias IoRzyExam.{Transactions, Accounts}
  alias IoRzyExam.Transactions.Transaction

  def index(conn, _params) do
    transactions = Transactions.list_transactions()

    render(conn, :index, transactions: transactions)
  end

  def edit(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    changeset = Transactions.change_transaction(transaction)
    render(conn, :edit, transaction: transaction, changeset: changeset)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Transactions.get_transaction!(id)

    with account <- Accounts.get_by_account_id!(transaction.account_id),
         {:ok, _auth} <- IoRzyExam.Client.Razoyo.authorize(account, transaction) do
      case Transactions.update_transaction(transaction, transaction_params) do
        {:ok, _transaction} ->
          conn
          |> put_flash(:info, "transaction updated successfully.")
          |> redirect(to: ~p"/transactions")

        {:error, %Ecto.Changeset{} = changeset} ->
          Logger.debug(inspect(changeset))
          render(conn, :edit, transaction: transaction, changeset: changeset)
      end
    else
      {:error, error} ->
        changeset =
          transaction
          |> Transaction.changeset(transaction_params)
          |> Ecto.Changeset.add_error(:secret, Map.get(error, "error"))

        render(conn, :edit,
          transaction: transaction,
          changeset: %{changeset | action: :update}
        )
    end
  end
end
