defmodule Numisma.Repo.Migrations.CreateCoinCorpus do
  use Ecto.Migration

  def change do
    create table(:coin_corpus) do
      add :coin_id, :string
    end
    create unique_index(:coin_corpus, [:coin_id])
  end
end
