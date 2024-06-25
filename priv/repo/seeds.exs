# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     IoRzyExam.Repo.insert!(%IoRzyExam.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias IoRzyExam.Client.Razoyo
alias IoRzyExam.{Accounts, Transactions}
alias IoRzyExam.Accounts.Account
alias IoRzyExam.Repo
alias IoRzyExam.Transactions.Transaction

defmodule IoRzyExam.Seeder do
  def insert_account(account_data, owner \\ false) do
    account_request = %{
      "type" => "GetAccount",
      "account" => Map.get(account_data, "account")
    }

    {:ok, %{"account" => %{"state" => state, "hint" => hint}}} =
      Razoyo.post_operations(account_request, Map.get(account_data, "access_token"))

    first_three =
      Base.decode64!(hint) |> String.replace("Starts with ", "") |> String.replace("__", "")

    routing_request = %{
      "type" => "GetRouting",
      "state" => state
    }

    {:ok, %{"routing_number" => routing}} =
      Razoyo.post_operations(routing_request, Map.get(account_data, "access_token"))

    account_data
    |> Map.put("state", state)
    |> Map.put("hint", first_three)
    |> Map.put("routing", routing)
    |> Map.put("state", state)
    |> Map.put("status", owner)
    |> Accounts.create_account()
  end

  def create_new_account do
    {:ok, account_data} = Razoyo.create_account()
    insert_account(account_data, true)
  end

  def insert_transactions(account) do
    {:ok, %{"transactions" => transaction_data}} =
      Razoyo.post_operations(%{"type" => "ListTransactions"}, account.access_token)

    Enum.each(transaction_data, fn transaction ->
      transaction
      |> Map.put("account_id", account.account)
      |> Transactions.create_transaction()
    end)
  end

  def insert_trx_accounts(access_token) do
    Transactions.list_transactions()
    |> Enum.map(fn trx -> trx.account end)
    |> Enum.uniq()
    |> Enum.each(fn account ->
      %{"account" => account, "access_token" => access_token}
      |> insert_account()

      :timer.sleep(500)
    end)
  end
end

Repo.delete_all(Transaction)
Repo.delete_all(Account)
{:ok, account} = IoRzyExam.Seeder.create_new_account()
IoRzyExam.Seeder.insert_transactions(account)
IoRzyExam.Seeder.insert_trx_accounts(account.access_token)
