defmodule IoRzyExam.Failures.Failure do
  use Ecto.Schema
  import Ecto.Changeset

  schema "failures" do
    field :account, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(failure, attrs) do
    failure
    |> cast(attrs, [:account])
    |> validate_required([:account])
  end
end
