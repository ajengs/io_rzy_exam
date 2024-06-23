defmodule IoRzyExam.Repo.Migrations.ModifyAccountsAddUniqueAccount do
  use Ecto.Migration

  def change do
    create unique_index(:accounts, [:account])
  end
end
