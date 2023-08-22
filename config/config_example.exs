import Config

config :tesla, adapter: Tesla.Adapter.Hackney
config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 40_000]}

config :numisma, ecto_repos: [Numisma.Repo]

config :numisma, Numisma.Repo,
  database: "numisma",
  username: "numisma",
  password: "",
  hostname: "",
  log: :info
