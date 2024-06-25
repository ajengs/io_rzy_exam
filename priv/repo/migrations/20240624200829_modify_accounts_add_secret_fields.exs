defmodule IoRzyExam.Repo.Migrations.ModifyAccountsAddSecretFields do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :hint, :string
      add :secret, :string
      add :amount, :decimal, precision: 17, scale: 2
    end
  end
end
