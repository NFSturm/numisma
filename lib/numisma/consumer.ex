defmodule Numisma.Consumer do

  alias Numisma.{
    OCREAPI,
    CoinDataParser,
    Coins.Coin,
    Repo
  }

  def start_link(coin_id) do
    Task.start_link(fn ->
      case OCREAPI.call_ocre_api(coin_id) do
        {:ok, body} ->
          CoinDataParser.parse_coin(body)
          |> then(fn parsed_coin ->
            %Coin{}
            |> Coin.changeset(parsed_coin)
            |> Repo.insert
          end)
        _ -> :ok
      end
    end)
  end

end
