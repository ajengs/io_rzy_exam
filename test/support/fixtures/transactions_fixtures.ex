defmodule IoRzyExam.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `IoRzyExam.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """

  def transaction_fixture(), do: transaction_fixture(%{})

  def transaction_fixture(%IoRzyExam.Accounts.Account{} = account) do
    {:ok, transaction} =
      %{
        account: "some account",
        amount: "120.50",
        company: "some company",
        time: ~N[2024-06-22 17:15:00],
        account_id: account.account
      }
      |> IoRzyExam.Transactions.create_transaction()

    transaction
  end

  def transaction_fixture(attrs) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        account: "some account",
        amount: "120.50",
        company: "some company",
        time: ~N[2024-06-22 17:15:00]
      })
      |> IoRzyExam.Transactions.create_transaction()

    transaction
  end
end
