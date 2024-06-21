defmodule IoRzyExam.Repo do
  use Ecto.Repo,
    otp_app: :io_rzy_exam,
    adapter: Ecto.Adapters.Postgres
end
