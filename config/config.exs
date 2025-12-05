# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :lunch_ninja,
  ecto_repos: [LunchNinja.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :lunch_ninja, LunchNinjaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LunchNinjaWeb.ErrorHTML, json: LunchNinjaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LunchNinja.PubSub,
  live_view: [signing_salt: "3xWjq8bW"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :lunch_ninja, LunchNinja.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  lunch_ninja: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  lunch_ninja: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Supabase configuration
config :lunch_ninja, :supabase,
  url: System.get_env("SUPABASE_URL") || "https://lcxnonpjokkpaocstzwc.supabase.co",
  anon_key:
    System.get_env("SUPABASE_ANON_KEY") ||
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxjeG5vbnBqb2trcGFvY3N0endjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4OTk5MzMsImV4cCI6MjA4MDQ3NTkzM30.TVoW4NSLM6ZVKSeJ-3It86jH2hwMS5cY0K2rE1nPVxw"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
