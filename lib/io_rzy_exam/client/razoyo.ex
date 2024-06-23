defmodule IoRzyExam.Client.Razoyo do
  alias IoRzyExam.HttpClient

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

  defp host_url do
    Application.get_env(:io_rzy_exam, :razoyo) |> Keyword.get(:host_url)
  end
end
