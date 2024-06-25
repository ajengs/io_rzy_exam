defmodule IoRzyExam.Client.RazoyoTest do
  use ExUnit.Case, async: true

  import Mox

  alias IoRzyExam.Client.Razoyo

  setup :verify_on_exit!

  @headers [{"Content-Type", "application/json"}]
  @account_headers [{"Authorization", "Bearer access-token"}] ++ @headers
  @access_token "access-token"

  @account %IoRzyExam.Accounts.Account{
    account: "account-number",
    state: "state",
    access_token: @access_token,
    routing: "routing-code"
  }
  @transaction %IoRzyExam.Transactions.Transaction{
    account: "trx-account",
    secret: "secret"
  }

  describe "create_account" do
    test "should pass a proper arguments and return correct response" do
      payload = %{"client_secret" => "client-secret"} |> Jason.encode!()

      resp_body = %{
        "account" => "account-number",
        "access_token" => @access_token
      }

      expect(HTTPMock, :post, fn "localhost/accounts", ^payload, @headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:ok, resp_body} == Razoyo.create_account()
    end

    test "should return error with html code on failed request" do
      resp_body = %{
        "error" => "forbidden"
      }

      expect(HTTPMock, :post, fn "localhost/accounts", _, _ ->
        {:ok, %HTTPoison.Response{status_code: 403, body: Jason.encode!(resp_body)}}
      end)

      assert {:error, %{body: resp_body, status_code: 403}} == Razoyo.create_account()
    end

    test "should return error on failed request" do
      resp_body = {:error, :nxdomain}

      expect(HTTPMock, :post, fn "localhost/accounts", _, _ -> resp_body end)

      assert Razoyo.create_account() == {:error, "nxdomain"}
    end
  end

  describe "post_operations/2" do
    test "ListTransactionsshould pass a proper arguments and return correct response" do
      req_body = %{"type" => "ListTransactions"}
      payload = Jason.encode!(req_body)

      resp_body = %{
        "transactions" => [
          %{
            "time" => "2024-06-15T07:30:00Z",
            "amount" => 100.00,
            "account" => "account-number",
            "company" => "company name"
          }
        ]
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:ok, resp_body} == Razoyo.post_operations(req_body, @access_token)
    end

    test "should return error with html code on failed request" do
      resp_body = %{
        "error" => "forbidden"
      }

      expect(HTTPMock, :post, fn "localhost/operations", _, _ ->
        {:ok, %HTTPoison.Response{status_code: 403, body: Jason.encode!(resp_body)}}
      end)

      assert {:error, "forbidden"} ==
               Razoyo.post_operations(%{}, @access_token)
    end

    test "should return error on failed request" do
      resp_body = {:error, :nxdomain}

      expect(HTTPMock, :post, fn "localhost/operations", _, _ -> resp_body end)

      assert Razoyo.post_operations(%{}, @access_token) == {:error, "nxdomain"}
    end

    test "GetAccount should pass a proper arguments and return correct response" do
      req_body = %{"type" => "GetAccount", "account" => @account.account}
      payload = Jason.encode!(req_body)

      resp_body = %{
        "account" => %{
          "state" => "Metro Manila",
          "hint" => "dW5hdmFpbGFibGU=",
          "city" => "Manila",
          "country" => "PH",
          "account" => @account.account,
          "company" => "(personal)"
        }
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:ok, resp_body} == Razoyo.post_operations(req_body, @account.access_token)
    end

    test "GetRouting should pass a proper arguments and return correct response" do
      req_body = %{"type" => "GetRouting", "state" => @account.state}
      payload = Jason.encode!(req_body)

      resp_body = %{
        "routing_number" => "routing-number"
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:ok, resp_body} == Razoyo.post_operations(req_body, @account.access_token)
    end

    test "Authorize should pass a proper arguments and return correct response" do
      req_body =
        %{
          "type" => "Authorize",
          "routing" => @account.routing,
          "account" => @transaction.account,
          "secret" => @transaction.secret
        }

      payload = Jason.encode!(req_body)

      resp_body = %{
        "token" => "authorized-token",
        "total" => 100.00,
        "error" => nil,
        "checks" => [
          %{"letter" => "w", "match" => "exact"}
        ]
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:ok, resp_body} == Razoyo.post_operations(req_body, @account.access_token)
    end

    test "Authorize should return error when error message not nil" do
      req_body =
        %{
          "type" => "Authorize",
          "routing" => @account.routing,
          "account" => @transaction.account,
          "secret" => @transaction.secret
        }

      payload = Jason.encode!(req_body)

      resp_body = %{
        "error" => "routing number invalid",
        "checks" => []
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:error, Map.get(resp_body, "error")} ==
               Razoyo.post_operations(req_body, @account.access_token)
    end

    test "Authorize should return error when checks not empty" do
      req_body =
        %{
          "type" => "Authorize",
          "routing" => @account.routing,
          "account" => @transaction.account,
          "secret" => @transaction.secret
        }

      payload = Jason.encode!(req_body)

      resp_body = %{
        "error" => "secret invalid",
        "checks" => [
          %{"letter" => "w", "match" => "exact"},
          %{"letter" => "h", "match" => "exact"},
          %{"letter" => "i", "match" => "exact"},
          %{"letter" => "p", "match" => "none"},
          %{"letter" => "s", "match" => "none"}
        ]
      }

      expected_error = """
      Letter w: exact; 
      Letter h: exact; 
      Letter i: exact; 
      Letter p: none; 
      Letter s: none; 
      """

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      # assert {:error, Map.get(resp_body, "checks") |> Jason.encode!()} ==
      # Razoyo.post_operations(req_body, @account.access_token)

      assert {:error, expected_error} ==
               Razoyo.post_operations(req_body, @account.access_token)
    end
  end
end
