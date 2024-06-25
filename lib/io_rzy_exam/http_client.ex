defmodule IoRzyExam.HttpClient do
  require Logger
  @headers [{"Content-Type", "application/json"}]

  def post(url, body, headers \\ []) do
    Logger.debug("Sending request to #{url} #{inspect(body)}")

    url
    |> http_client().post(body, headers ++ @headers)
    |> process_response_body()
  end

  def get(url, headers \\ []) do
    Logger.debug("Sending request to #{url}")

    url
    |> http_client().get(headers ++ @headers)
    |> process_response_body()
  end

  defp process_response_body({:ok, %HTTPoison.Response{status_code: status_code, body: body}})
       when status_code in [200, 201, 202, 204],
       do: {:ok, parse_body(body)}

  defp process_response_body({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    {
      :error,
      %{
        status_code: status_code,
        body: parse_body(body)
      }
    }
  end

  defp process_response_body({:error, %HTTPoison.Error{reason: {_, reason}}}),
    do: {:error, reason}

  defp process_response_body({:error, %HTTPoison.Error{reason: reason}}),
    do: {:error, reason}

  defp process_response_body({:error, reason}) when is_atom(reason),
    do: {:error, Atom.to_string(reason)}

  defp process_response_body({:error, reason}),
    do: {:error, reason}

  defp parse_body(body) do
    with {:ok, body} <- Jason.decode(body) do
      body
    else
      _ -> body
    end
  end

  defp http_client do
    Application.get_env(:io_rzy_exam, :http_client)
  end
end
