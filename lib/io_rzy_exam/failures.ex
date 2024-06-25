defmodule IoRzyExam.Failures do
  @moduledoc """
  The Failures context.
  """

  import Ecto.Query, warn: false
  alias IoRzyExam.Repo

  alias IoRzyExam.Failures.Failure

  @doc """
  Returns the list of failures.

  ## Examples

      iex> list_failures()
      [%Failure{}, ...]

  """
  def list_failures do
    Repo.all(Failure)
  end

  def list_failures(query) do
    Repo.all(query)
  end

  @doc """
  Gets a single failure.

  Raises `Ecto.NoResultsError` if the Failure does not exist.

  ## Examples

      iex> get_failure!(123)
      %Failure{}

      iex> get_failure!(456)
      ** (Ecto.NoResultsError)

  """
  def get_failure!(id), do: Repo.get!(Failure, id)

  @doc """
  Creates a failure.

  ## Examples

      iex> create_failure(%{field: value})
      {:ok, %Failure{}}

      iex> create_failure(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_failure(attrs \\ %{}) do
    %Failure{}
    |> Failure.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a failure.

  ## Examples

      iex> update_failure(failure, %{field: new_value})
      {:ok, %Failure{}}

      iex> update_failure(failure, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_failure(%Failure{} = failure, attrs) do
    failure
    |> Failure.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a failure.

  ## Examples

      iex> delete_failure(failure)
      {:ok, %Failure{}}

      iex> delete_failure(failure)
      {:error, %Ecto.Changeset{}}

  """
  def delete_failure(%Failure{} = failure) do
    Repo.delete(failure)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking failure changes.

  ## Examples

      iex> change_failure(failure)
      %Ecto.Changeset{data: %Failure{}}

  """
  def change_failure(%Failure{} = failure, attrs \\ %{}) do
    Failure.changeset(failure, attrs)
  end

  def within_timeframe do
    time_window =
      DateTime.add(DateTime.utc_now(), Application.get_env(:io_rzy_exam, :failure_timeframe) * -1)

    from(f in Failure, where: f.updated_at > ^time_window)
  end
end
