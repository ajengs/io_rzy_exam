defmodule IoRzyExam.Repo.Migrations.ModifyTransactionsAddSecret do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :secret, :string
    end
  end
end
