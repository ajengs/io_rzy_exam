defmodule IoRzyExam.Client.Razoyo do
  alias IoRzyExam.HttpClient

  def create_account do
    request_body = %{
      "client_secret" => client_secret()
    }

    HttpClient.post(
      host_url() <> "/accounts",
      Jason.encode!(request_body)
    )
  end

  def list_transactions(access_token) do
    request_body = %{
      "type" => "ListTransactions"
    }

    HttpClient.post(
      host_url() <> "/operations",
      Jason.encode!(request_body),
      [{"Authorization", "Bearer " <> access_token}]
    )
  end

  def get_account(account) do
    request_body = %{
      "type" => "GetAccount",
      "account" => account.account
    }

    HttpClient.post(
      host_url() <> "/operations",
      Jason.encode!(request_body),
      [{"Authorization", "Bearer " <> account.access_token}]
    )
  end

  def get_routing(account) do
    request_body = %{
      "type" => "GetRouting",
      "state" => account.state
    }

    HttpClient.post(
      host_url() <> "/operations",
      Jason.encode!(request_body),
      [{"Authorization", "Bearer " <> account.access_token}]
    )
  end

  def authorize(account, transaction) do
    request_body = %{
      "type" => "Authorize",
      "routing" => account.routing,
      "account" => transaction.account,
      "secret" => transaction.secret
    }

    res =
      HttpClient.post(
        host_url() <> "/operations",
        Jason.encode!(request_body),
        [{"Authorization", "Bearer " <> account.access_token}]
      )

    case res do
      {:ok, %{"error" => error_message} = error} when not is_nil(error_message) -> {:error, error}
      _ -> res
    end
  end

  defp client_secret do
    Application.get_env(:io_rzy_exam, :razoyo) |> Keyword.get(:client_secret)
  end

  defp host_url do
    Application.get_env(:io_rzy_exam, :razoyo) |> Keyword.get(:host_url)
  end
end
