defmodule IoRzyExam.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IoRzyExamWeb.Telemetry,
      IoRzyExam.Repo,
      {DNSCluster, query: Application.get_env(:io_rzy_exam, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: IoRzyExam.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: IoRzyExam.Finch},
      # Start a worker by calling: IoRzyExam.Worker.start_link(arg)
      # {IoRzyExam.Worker, arg},
      # Start to serve requests, typically the last entry
      IoRzyExamWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IoRzyExam.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IoRzyExamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
