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

  def list_transactions do
    request_body = %{
      "type" => "ListTransactions"
    }

    HttpClient.post(
      host_url() <> "/operations",
      Jason.encode!(request_body),
      [{"Authorization", "Bearer " <> access_token()}]
    )
  end

  defp access_token do
    Application.get_env(:io_rzy_exam, :razoyo) |> Keyword.get(:access_token)
  end

  defp client_secret do
    Application.get_env(:io_rzy_exam, :razoyo) |> Keyword.get(:client_secret)
  end

  defp host_url do
    Application.get_env(:io_rzy_exam, :razoyo) |> Keyword.get(:host_url)
  end
end
