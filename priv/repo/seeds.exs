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

Repo.delete_all(Transaction)
Repo.delete_all(Account)

create_transactions = fn data ->
  Enum.map(data, fn v ->
    Transactions.create_transaction(v)
  end)
end

with {:ok, account_data} <- Razoyo.create_account(),
     {:ok, account} <- Accounts.create_account(account_data),
     {:ok, %{"transactions" => transaction_data}} <-
       Razoyo.list_transactions(account.access_token) do
  create_transactions.(transaction_data)
  IO.puts("SUCCESS: " <> inspect(account))
else
  err -> IO.puts("ERROR: " <> inspect(err))
end
