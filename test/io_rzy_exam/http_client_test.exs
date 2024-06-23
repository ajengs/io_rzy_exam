defmodule IoRzyExam.HttpClientTest do
  use ExUnit.Case, async: true

  import Mox

  alias IoRzyExam.HttpClient

  setup :verify_on_exit!

  @headers [{"Content-Type", "application/json"}]

  test "should pass a proper arguments" do
    url = "url"
    payload = %{}

    expect(HTTPMock, :post, 2, fn ^url, ^payload, @headers ->
      {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
    end)

    HttpClient.post(url, payload)
    HttpClient.post(url, payload, [])
  end

  test "should return a custom error" do
    error = {:error, :nxdomain}

    expect(HTTPMock, :post, fn _, _, _ -> error end)

    assert ^error = HttpClient.post("url", "payload")
  end

  test "should return simple HTTPoison.Error" do
    reason = "reason"
    error = {:error, %HTTPoison.Error{reason: reason}}

    expect(HTTPMock, :post, fn _, _, _ -> error end)

    assert {:error, ^reason} = HttpClient.post("url", "payload", [])
  end

  test "should return complex HTTPoison.Error" do
    reason = "reason"
    error = {:error, %HTTPoison.Error{reason: {:error, reason}}}

    expect(HTTPMock, :post, fn _, _, _ -> error end)

    assert {:error, ^reason} = HttpClient.post("url", "payload", [])
  end

  test "should return 404 response" do
    body = "body"
    url = "url"
    code = 404
    error = {:ok, %HTTPoison.Response{status_code: code, body: body}}

    expect(HTTPMock, :post, fn _, _, _ -> error end)

    assert {
             :error,
             %{
               body: ^body,
               status_code: ^code
             }
           } = HttpClient.post(url, "payload", [])
  end

  test "should return 200 response" do
    body = "body"
    resp = {:ok, %HTTPoison.Response{status_code: 200, body: body}}

    expect(HTTPMock, :post, fn _, _, _ -> resp end)

    assert {
             :ok,
             ^body
           } = HttpClient.post("url", "payload", [])
  end
end
