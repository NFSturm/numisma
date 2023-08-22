defmodule Numisma.Coins.Coin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "coins" do
    field :coin_id, :string
    field :authority, :string
    field :start_date, :string
    field :end_date, :string
    field :region, :string
    field :mint, :string
    field :denomination, :string
    field :obverse_portrait, :string
    field :reverse_portrait, :string
    field :obverse_legend, :string
    field :reverse_legend, :string
  end

  @doc false
  def changeset(coin_metadata, attrs) do
    coin_metadata
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:coin_id, :start_date, :end_date])
    |> unique_constraint(:coin_id)
  end

end
