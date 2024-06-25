defmodule IoRzyExam.Repo.Migrations.CreateFailures do
  use Ecto.Migration

  def change do
    create table(:failures) do
      add :account, :string

      timestamps(type: :utc_datetime)
    end
  end
end
