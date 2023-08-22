defmodule Numisma.Repo.Migrations.CreateCoin do
  use Ecto.Migration

  def change do
    create table(:coins) do
      add :coin_id, :string
      add :authority, :string
      add :start_date, :string
      add :end_date, :string
      add :region, :string
      add :mint, :string
      add :denomination, :string
      add :obverse_portrait, :string
      add :reverse_portrait, :string
      add :obverse_legend, :string
      add :reverse_legend, :string
    end
    create unique_index(:coins, [:coin_id])
  end
end
