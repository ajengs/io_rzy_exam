import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :io_rzy_exam,
  http_client: HTTPMock

config :io_rzy_exam, IoRzyExam.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "io_rzy_exam_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :io_rzy_exam, IoRzyExamWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "NojRim2yKLxKbG7iggj1pNjNclptuyuYiJX5fguC6G56ZPoR0K5FL3uK6cfBKZSZ",
  server: false

# In test we don't send emails.
config :io_rzy_exam, IoRzyExam.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
