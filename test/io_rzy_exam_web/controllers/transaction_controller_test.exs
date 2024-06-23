defmodule IoRzyExamWeb.TransactionControllerTest do
  use IoRzyExamWeb.ConnCase

  describe "index" do
    test "lists all transactions", %{conn: conn} do
      conn = get(conn, ~p"/transactions")
      assert html_response(conn, 200) =~ "Account Transactions"
    end
  end
end
