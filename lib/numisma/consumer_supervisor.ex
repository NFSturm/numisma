defmodule Numisma.ConsumerSupervisor do
  use ConsumerSupervisor

  alias Numisma.{Producer, Consumer}

  def start_link(_opts) do
    ConsumerSupervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      %{
        id: NumismaConsumer,
        start: {Consumer, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      max_restarts: 10,
      subscribe_to: [
        {Producer, min_demand: 0, max_demand: 3},
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
