defmodule IoRzyExam.Client.RazoyoTest do
  use ExUnit.Case, async: true

  import Mox

  alias IoRzyExam.Client.Razoyo

  setup :verify_on_exit!

  @headers [{"Content-Type", "application/json"}]

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

    assert {:ok, resp_body} == Razoyo.list_transactions()
  end

  test "should return error with html code on failed request" do
    resp_body = %{
      "error" => "forbidden"
    }

    expect(HTTPMock, :post, fn "localhost/operations", _, _ ->
      {:ok, %HTTPoison.Response{status_code: 403, body: Jason.encode!(resp_body)}}
    end)

    assert {:error, %{body: resp_body, status_code: 403}} == Razoyo.list_transactions()
  end

  test "should return error on failed request" do
    resp_body = {:error, :nxdomain}

    expect(HTTPMock, :post, fn "localhost/operations", _, _ -> resp_body end)

    assert Razoyo.list_transactions() == resp_body
  end
end
