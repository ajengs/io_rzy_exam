defmodule IoRzyExam.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :status, :boolean, default: false
    field :state, :string
    field :account, :string
    field :access_token, :string
    field :routing, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:account, :access_token, :status, :state, :routing])
    |> validate_required([:account, :access_token, :status, :state, :routing])
  end
end
