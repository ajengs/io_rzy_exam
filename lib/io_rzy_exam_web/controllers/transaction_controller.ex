defmodule IoRzyExamWeb.TransactionController do
  use IoRzyExamWeb, :controller

  alias IoRzyExam.Transactions

  def index(conn, _params) do
    transactions = Transactions.list_transactions()

    render(conn, :index, transactions: transactions)
  end
end
