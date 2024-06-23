defmodule IoRzyExamWeb.AccountController do
  use IoRzyExamWeb, :controller

  # alias IoRzyExam.Client.Razoyo

  def index(conn, _params) do
    with {:ok, data} <- {:ok, %{"transactions" => []}} do
      render(conn, :index, transactions: Map.get(data, "transactions"), layout: false)
    end
  end
end
