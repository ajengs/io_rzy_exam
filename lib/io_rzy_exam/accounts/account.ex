defmodule IoRzyExam.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :account, :string
    field :access_token, :string
    field :status, :boolean, default: true
    field :state, :string
    field :routing, :string
    field :hint, :string
    field :secret, :string
    field :amount, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :account,
      :access_token,
      :status,
      :state,
      :routing,
      :hint,
      :secret,
      :amount
    ])
    |> validate_required([:account, :access_token, :status])
  end
end
