defmodule IoRzyExam.Client.Words do
  alias IoRzyExam.HttpClient

  def get_word(word) when not is_nil(word) and word != "" do
    res =
      HttpClient.get(
        host_url() <> "/" <> word,
        [{"x-rapidapi-key", api_key()}]
      )

    case res do
      {:error, %{body: %{"message" => message, "success" => false}}} ->
        {:error, message}

      _ ->
        res
    end
  end

  def get_word(_), do: {:error, "Word cannot be empty"}

  defp api_key do
    Application.get_env(:io_rzy_exam, :words_api) |> Keyword.get(:api_key)
  end

  defp host_url do
    Application.get_env(:io_rzy_exam, :words_api) |> Keyword.get(:host_url)
  end
end
