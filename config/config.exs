# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :prueba, PruebaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OhKVFxZ5qpKYN7d8XeLr6Cmy9QcXQf+Rwmtd9KnNXCWfH6gOzL7kVbhJAVf9o4F7",
  render_errors: [view: PruebaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Prueba.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

import_config "#{Mix.env()}.exs"
