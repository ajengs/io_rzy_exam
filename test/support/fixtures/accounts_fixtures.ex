defmodule IoRzyExam.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `IoRzyExam.Accounts` context.
  """

  def dummy_account do
    %{
      access_token: "some access_token",
      account: "some account",
      routing: "some routing",
      state: "some state",
      status: true
    }
  end

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      dummy_account()
      |> Map.merge(attrs)
      |> IoRzyExam.Accounts.create_account()

    account
  end
end
