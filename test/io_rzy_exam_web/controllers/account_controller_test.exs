defmodule IoRzyExamWeb.AccountsControllerTest do
  use IoRzyExamWeb.ConnCase

  import IoRzyExam.AccountsFixtures
  import IoRzyExam.FailuresFixtures
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

    test "restrict edit if failures > 3", %{conn: conn, account: account} do
      Enum.each(1..4, fn _ -> failure_fixture() end)
      conn = get(conn, ~p"/accounts/#{account}/edit")
      assert html_response(conn, 302)

      assert conn.assigns |> Map.get(:flash) |> Map.get("error") ==
               "Too many authorization failures. Try again later."
    end
  end

  describe "update account" do
    setup [:create_account]

    test "redirects when data is valid", %{conn: conn, account: account} do
      payload =
        %{
          "account" => "some account",
          "routing" => "some routing",
          "secret" => "secret word",
          "type" => "Authorize"
        }
        |> Jason.encode!()

      resp_body = %{
        "token" => "authorized-token",
        "total" => 100.00,
        "error" => nil
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, _account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      conn =
        put(conn, ~p"/accounts/#{account}",
          account: %{routing: account.routing, account: account.account, secret: "secret word"}
        )

      assert redirected_to(conn) == ~p"/accounts"

      assert %{secret: "authorized-token"} = IoRzyExam.Accounts.get_account!(account.id)
    end

    test "renders errors when authorization failed", %{conn: conn, account: account} do
      resp_body = %{
        "error" => "routing number invalid",
        "checks" => []
      }

      expect(HTTPMock, :post, fn "localhost/operations", _payload, _account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      conn = put(conn, ~p"/accounts/#{account}", account: %{secret: "secret word"})
      assert html_response(conn, 200) =~ "routing number invalid"
    end

    test "restrict update if failures > 3", %{conn: conn, account: account} do
      Enum.each(1..4, fn _ -> failure_fixture() end)
      conn = put(conn, ~p"/accounts/#{account}", account: %{secret: "secret word"})
      assert html_response(conn, 302)

      assert conn.assigns |> Map.get(:flash) |> Map.get("error") ==
               "Too many authorization failures. Try again later."
    end

    test "renders errors when submitted data is invalid", %{conn: conn, account: account} do
      conn = put(conn, ~p"/accounts/#{account}", account: %{account: ""})
      assert html_response(conn, 200) =~ "Update secret"
    end
  end

  describe "transfer" do
    test "transfer to authorized accounts", %{conn: conn} do
      account_fixture(%{status: false, secret: "secret", amount: "100"})

      resp_body = %{
        "total" => 100
      }

      payload =
        %{
          "type" => "Transfer",
          "authorizations" => ["secret"],
          "total" => "100.00"
        }
        |> Jason.encode!()

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, _account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      conn = post(conn, ~p"/transfers")
      assert html_response(conn, 302)

      assert conn.assigns |> Map.get(:flash) |> Map.get("info") ==
               "Funds transferred successfully!"
    end

    test "transfer failed if no authorized accounts found", %{conn: conn} do
      conn = post(conn, ~p"/transfers")
      assert html_response(conn, 302)

      assert conn.assigns |> Map.get(:flash) |> Map.get("error") ==
               "No authorized accounts found!"
    end
  end

  defp create_account(_) do
    account = account_fixture()
    %{account: account}
  end
end
