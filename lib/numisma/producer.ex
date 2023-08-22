defmodule Numisma.Producer do
  use GenStage

  use Tesla

  alias Numisma.{
    OCREAPI,
    Coins.Coin,
    Corpus.CoinCorpus,
    Repo
  }

  import Ecto.Query

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, OCREAPI.paginate_requests(), name: __MODULE__)
  end

  def init(site_requests) do
    {:producer, %{site_requests: site_requests}}
  end

  def handle_demand(_demand, %{site_requests: []} = state) do

    GenStage.async_info(self(), :events_finished)

    {:noreply, [], state, :hibernate}
  end

  def handle_demand(demand, %{site_requests: site_requests} = _state) do

    sites_to_emit =
      site_requests
      |> Enum.take(demand)

    coin_ids = for site <- sites_to_emit, into: [] do
      case OCREAPI.request_coin_browser(site) do
        nil -> nil
        body -> get_coin_ids(body)
      end
    end

    corpus_coins = for coin_id <- List.flatten(coin_ids), into: [] do
      %{coin_id: coin_id}
    end

    Repo.insert_all(CoinCorpus, corpus_coins,
      on_conflict: {:replace, [:coin_id]},
      conflict_target: :coin_id
    )

    existing_coin_ids =
      (from c in Coin, select: c.coin_id)
      |> Repo.all

    coin_ids_flat = coin_ids
      |> List.flatten
      |> Enum.reject(fn id -> Enum.member?(existing_coin_ids, id) end)

    remaining_sites =
      site_requests
      |> Enum.reject(fn element -> Enum.member?(sites_to_emit, element) end)

    {:noreply, coin_ids_flat, %{site_requests: remaining_sites}}
  end

  def get_coin_ids(body) do

    {:ok, document} = Floki.parse_document(body)

    document
      |> Floki.find("h4")
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.filter(fn id -> String.contains?(id, "id/") end)
      |> Enum.map(fn coin_id ->
        "id/" <> ric_id = coin_id
        ric_id
      end)
  end

  def handle_info(:events_finished, state) do
    {:stop, :normal, state}
  end

end
