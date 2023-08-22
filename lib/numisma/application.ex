defmodule Numisma.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Numisma.{Producer, ConsumerSupervisor}

  @impl true
  def start(_type, _args) do
    children = [
      Numisma.Repo,
      Producer,
      ConsumerSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Numisma.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
