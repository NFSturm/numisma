defmodule Numisma.Corpus.CoinCorpus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "coin_corpus" do
    field :coin_id, :string
  end

  @doc false
  def changeset(coin_metadata, attrs) do
    coin_metadata
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:coin_id])
    |> unique_constraint(:coin_id)
  end

end
