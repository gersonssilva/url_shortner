import Config

# Configure your database
config :url_shortner, UrlShortner.Repo,
  url:
    System.get_env("DATABASE_URL", "postgresql://postgres:postgres@localhost/url_shortner_dev"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.

port = String.to_integer(System.get_env("PORT") || "4000")

config :url_shortner, UrlShortnerWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: port],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "o5XNIq1+OvGcCKWePuGK+Bq2TFlvM201BQyuWNMXvOqi2Q+0eairFEtWNsAMax2I",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:url_shortner, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:url_shortner, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :url_shortner, UrlShortnerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/url_shortner_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :url_shortner, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
