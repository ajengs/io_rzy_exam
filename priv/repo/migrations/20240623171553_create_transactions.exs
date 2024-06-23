defmodule IoRzyExam.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :account, :string
      add :company, :string
      add :amount, :decimal, precision: 17, scale: 2
      add :time, :naive_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
