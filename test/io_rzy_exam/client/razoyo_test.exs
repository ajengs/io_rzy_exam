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

      assert Razoyo.create_account() == resp_body
    end
  end

  describe "list_transactions/1" do
    test "should pass a proper arguments and return correct response" do
      payload = %{"type" => "ListTransactions"} |> Jason.encode!()

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

      assert {:ok, resp_body} == Razoyo.list_transactions(@access_token)
    end

    test "should return error with html code on failed request" do
      resp_body = %{
        "error" => "forbidden"
      }

      expect(HTTPMock, :post, fn "localhost/operations", _, _ ->
        {:ok, %HTTPoison.Response{status_code: 403, body: Jason.encode!(resp_body)}}
      end)

      assert {:error, %{body: resp_body, status_code: 403}} ==
               Razoyo.list_transactions(@access_token)
    end

    test "should return error on failed request" do
      resp_body = {:error, :nxdomain}

      expect(HTTPMock, :post, fn "localhost/operations", _, _ -> resp_body end)

      assert Razoyo.list_transactions(@access_token) == resp_body
    end
  end

  describe "get_account/1" do
    test "should pass a proper arguments and return correct response" do
      payload = %{"type" => "GetAccount", "account" => @account.account} |> Jason.encode!()

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

      assert {:ok, resp_body} == Razoyo.get_account(@account)
    end
  end

  describe "get_routing/1" do
    test "should pass a proper arguments and return correct response" do
      payload = %{"type" => "GetRouting", "state" => @account.state} |> Jason.encode!()

      resp_body = %{
        "routing_number" => "routing-number"
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:ok, resp_body} == Razoyo.get_routing(@account)
    end
  end

  describe "authorize/2" do
    test "should pass a proper arguments and return correct response" do
      payload =
        %{
          "type" => "Authorize",
          "routing" => @account.routing,
          "account" => @transaction.account,
          "secret" => @transaction.secret
        }
        |> Jason.encode!()

      resp_body = %{
        "token" => "authorized-token",
        "total" => 100.00,
        "error" => nil
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:ok, resp_body} == Razoyo.authorize(@account, @transaction)
    end

    test "should return error when error message not nil" do
      payload =
        %{
          "type" => "Authorize",
          "routing" => @account.routing,
          "account" => @transaction.account,
          "secret" => @transaction.secret
        }
        |> Jason.encode!()

      resp_body = %{
        "error" => "routing number invalid",
        "checks" => []
      }

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, @account_headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:error, resp_body} == Razoyo.authorize(@account, @transaction)
    end
  end
end
