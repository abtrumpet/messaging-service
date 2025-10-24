import Config

config :messaging_service,
  ecto_repos: [MessagingService.Repo],
  generators: [timestamp_type: :utc_datetime]

config :messaging_service, MessagingServiceWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MessagingServiceWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MessagingService.PubSub

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# Suppress Tesla deprecation warning for builder usage
config :tesla, :adapter, Tesla.Adapter.Hackney

import_config "#{config_env()}.exs"
