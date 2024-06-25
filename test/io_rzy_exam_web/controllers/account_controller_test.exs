defmodule IoRzyExamWeb.AccountsControllerTest do
  use IoRzyExamWeb.ConnCase

  import IoRzyExam.AccountsFixtures
  import Mox
  setup :verify_on_exit!

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      conn = get(conn, ~p"/accounts")
      assert html_response(conn, 200) =~ "Account List"
    end
  end

  describe "edit account" do
    setup [:create_account]

    test "renders form for editing chosen account", %{conn: conn, account: account} do
      conn = get(conn, ~p"/accounts/#{account}/edit")
      assert html_response(conn, 200) =~ "Update secret"
    end
  end

  # describe "update transaction" do
  #   setup [:create_transaction_with_account]

  #   test "redirects when data is valid", %{conn: conn, transaction: transaction} do
  #     resp_body = %{
  #       "token" => "authorized-token",
  #       "total" => 100.00,
  #       "error" => nil
  #     }

  #     expect(HTTPMock, :post, fn "localhost/operations", _payload, _account_headers ->
  #       {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
  #     end)

  #     conn = put(conn, ~p"/transactions/#{transaction}", transaction: %{secret: "updated-secret"})
  #     assert redirected_to(conn) == ~p"/transactions"

  #     assert %{secret: "updated-secret"} = IoRzyExam.Transactions.get_transaction!(transaction.id)
  #   end

  #   test "renders errors when authorization failed", %{conn: conn, transaction: transaction} do
  #     resp_body = %{
  #       "error" => "routing number invalid",
  #       "checks" => []
  #     }

  #     expect(HTTPMock, :post, fn "localhost/operations", _payload, _account_headers ->
  #       {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
  #     end)

  #     conn = put(conn, ~p"/transactions/#{transaction}", transaction: %{secret: "updated-secret"})
  #     assert html_response(conn, 200) =~ "routing number invalid"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, transaction: transaction} do
  #     expect(HTTPMock, :post, fn "localhost/operations", _payload, _account_headers ->
  #       {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
  #     end)

  #     conn = put(conn, ~p"/transactions/#{transaction}", transaction: %{account: nil})
  #     assert html_response(conn, 200) =~ "Update secret"
  #   end
  # end

  defp create_account(_) do
    account = account_fixture()
    %{account: account}
  end

  # defp create_transaction_with_account(_) do
  #   account = account_fixture()
  #   transaction = transaction_fixture(account)
  #   %{transaction: transaction}
  # end
end
