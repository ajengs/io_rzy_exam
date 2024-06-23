defmodule IoRzyExam.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :time, :naive_datetime
    field :account, :string
    field :company, :string
    field :amount, :decimal
    field :secret, :string
    belongs_to :accounts, IoRzyExam.Accounts.Account, foreign_key: :account_id, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:account, :company, :amount, :time, :secret, :account_id])
    |> validate_required([:account, :company, :amount, :time])
  end
end
