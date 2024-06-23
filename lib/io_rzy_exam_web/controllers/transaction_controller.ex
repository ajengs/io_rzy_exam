defmodule IoRzyExamWeb.TransactionController do
  use IoRzyExamWeb, :controller

  alias IoRzyExam.Transactions

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

    case Transactions.update_transaction(transaction, transaction_params) do
      {:ok, _transaction} ->
        conn
        |> put_flash(:info, "transaction updated successfully.")
        |> index(%{})

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, transaction: transaction, changeset: changeset)
    end
  end
end
