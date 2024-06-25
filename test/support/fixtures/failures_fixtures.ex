defmodule IoRzyExam.FailuresFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `IoRzyExam.Failures` context.
  """

  @doc """
  Generate a failure.
  """
  def failure_fixture(attrs \\ %{}) do
    {:ok, failure} =
      attrs
      |> Enum.into(%{
        account: "some account"
      })
      |> IoRzyExam.Failures.create_failure()

    failure
  end
end
