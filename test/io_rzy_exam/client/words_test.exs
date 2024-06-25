defmodule IoRzyExam.Client.WordsTest do
  use ExUnit.Case, async: true

  import Mox

  alias IoRzyExam.Client.Words

  setup :verify_on_exit!

  @headers [{"x-rapidapi-key", "api-key"}, {"Content-Type", "application/json"}]

  describe "get_word/1" do
    test "should pass a proper arguments and return correct response" do
      resp_body = %{
        "word" => "hello",
        "results" => [
          %{
            "definition" => "an expression of greeting",
            "partOfSpeech" => "noun"
          }
        ]
      }

      expect(HTTPMock, :get, fn "localhost/hello", @headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(resp_body)}}
      end)

      assert {:ok, resp_body} == Words.get_word("hello")
    end

    test "should return error with html code on failed request" do
      resp_body = %{
        "success" => false,
        "message" => "word not found"
      }

      expect(HTTPMock, :get, fn "localhost/abcde", _ ->
        {:ok, %HTTPoison.Response{status_code: 404, body: Jason.encode!(resp_body)}}
      end)

      assert {:error, "word not found"} == Words.get_word("abcde")
    end

    test "should return error on failed request" do
      resp_body = {:error, :nxdomain}

      expect(HTTPMock, :get, fn "localhost/hello", _ -> resp_body end)

      assert Words.get_word("hello") == {:error, "nxdomain"}
    end

    test "should return error without sending request if word is null" do
      assert Words.get_word("") == {:error, "Word cannot be empty"}
      assert Words.get_word(nil) == {:error, "Word cannot be empty"}
    end
  end
end
