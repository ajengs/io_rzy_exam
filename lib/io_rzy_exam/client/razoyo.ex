defmodule IoRzyExam.Client.Razoyo do
  require Logger
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

  def post_operations(request_body, access_token) do
    HttpClient.post(
      host_url() <> "/operations",
      Jason.encode!(request_body),
      [{"Authorization", "Bearer " <> access_token}]
    )
    |> render_response
  end

  defp render_response(res) do
    Logger.debug(inspect(res))

    case res do
      {:ok, %{"error" => error_message, "checks" => checks}}
      when not is_nil(error_message) and checks != [] ->
        {:error, parse_check_result(checks)}

      {:ok, %{"error" => error_message}} when not is_nil(error_message) ->
        {:error, error_message}

      {:error,
       %{
         body: %{"error" => error}
       }} ->
        {:error, error}

      _ ->
        res
    end
  end

  defp parse_check_result(checks) do
    Enum.reduce(checks, "", fn c, acc ->
      res = "Letter " <> Map.get(c, "letter") <> ": " <> Map.get(c, "match")
      acc <> res <> "; \n"
    end)
  end

  defp client_secret do
    Application.get_env(:io_rzy_exam, :razoyo) |> Keyword.get(:client_secret)
  end

  defp host_url do
    Application.get_env(:io_rzy_exam, :razoyo) |> Keyword.get(:host_url)
  end
end
