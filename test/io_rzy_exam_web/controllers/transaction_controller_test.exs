defmodule IoRzyExamWeb.TransactionControllerTest do
  use IoRzyExamWeb.ConnCase

  import IoRzyExam.TransactionsFixtures

  describe "index" do
    test "lists all transactions", %{conn: conn} do
      conn = get(conn, ~p"/transactions")
      assert html_response(conn, 200) =~ "Account Transactions"
    end
  end

  describe "edit transaction" do
    setup [:create_transaction]

    test "renders form for editing chosen transaction", %{conn: conn, transaction: transaction} do
      conn = get(conn, ~p"/transactions/#{transaction}/edit")
      assert html_response(conn, 200) =~ "Update secret"
    end
  end

  defp create_transaction(_) do
    transaction = transaction_fixture()
    %{transaction: transaction}
  end
end
