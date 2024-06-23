# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :io_rzy_exam,
  ecto_repos: [IoRzyExam.Repo],
  generators: [timestamp_type: :utc_datetime],
  http_client: HTTPoison

# Configures the endpoint
config :io_rzy_exam, IoRzyExamWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: IoRzyExamWeb.ErrorHTML, json: IoRzyExamWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: IoRzyExam.PubSub,
  live_view: [signing_salt: "tOvWB75V"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :io_rzy_exam, IoRzyExam.Mailer, adapter: Swoosh.Adapters.Local

config :io_rzy_exam, :razoyo,
  host_url: "https://exam.razoyo.com/api/banking",
  client_secret: "qRIAKP5ywR5i6sGcv3dFbYDEKoUmV5V5",
  account: "1719159858114201-4261",
  access_token:
    "SFMyNTY.g2gDbQAAABUxNzE5MTU5ODU4MTE0MjAxLTQyNjFuBgARpOlFkAFiAAFRgA.iWXRKGBiPfdQcLhe0RXQK2eYPOBvK3DjcAV-V4iSNKY"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  io_rzy_exam: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  io_rzy_exam: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
