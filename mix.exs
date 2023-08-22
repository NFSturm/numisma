defmodule Numisma.MixProject do
  use Mix.Project

  def project do
    [
      app: :numisma,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Numisma.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:jason, "~> 1.4"},
      {:ecto, "~> 3.9"},
      {:ecto_sql, "~> 3.9"},
      {:postgrex, "~> 0.16.5"},
      {:gen_stage, "~> 1.2"},
      {:timex, "~> 3.0"},
      {:focus, "~> 0.4.0"},
      {:floki, "~> 0.34.0"},
      {:html5ever, "~> 0.14.0"}
    ]
  end
end
