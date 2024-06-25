defmodule IoRzyExam.Repo.Migrations.ModifyAccountAddTransferFlag do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :transferred, :boolean, default: false
    end
  end
end
