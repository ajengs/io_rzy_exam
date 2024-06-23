defmodule IoRzyExam.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :account, :string
      add :access_token, :string
      add :status, :boolean, default: true, null: false
      add :state, :string
      add :routing, :string

      timestamps(type: :utc_datetime)
    end
  end
end
