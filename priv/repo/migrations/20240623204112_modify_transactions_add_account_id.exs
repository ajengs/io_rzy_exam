defmodule IoRzyExam.Repo.Migrations.ModifyTransactionsAddAccountId do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :account_id, references(:accounts , on_delete: :nothing, column: :account, type: :string)
    end
  end
end
