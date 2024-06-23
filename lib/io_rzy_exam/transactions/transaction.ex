defmodule IoRzyExam.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :time, :naive_datetime
    field :account, :string
    field :company, :string
    field :amount, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:account, :company, :amount, :time])
    |> validate_required([:account, :company, :amount, :time])
  end
end
