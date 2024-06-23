defmodule IoRzyExam.Client.RazoyoTest do
  use ExUnit.Case, async: true

  import Mox

  alias IoRzyExam.Client.Razoyo

  setup :verify_on_exit!

  @headers [{"Content-Type", "application/json"}]
  @access_token "access-token"

  describe "create_account" do
    test "should pass a proper arguments and return correct response" do
      payload = %{"client_secret" => "client-secret"} |> Jason.encode!()

      resp_body = %{
        "account" => "account-number",
        "access_token" => "access-token"
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
      headers = [{"Authorization", "Bearer access-token"}] ++ @headers

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

      expect(HTTPMock, :post, fn "localhost/operations", ^payload, ^headers ->
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
end
