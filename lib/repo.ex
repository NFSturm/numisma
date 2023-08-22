defmodule Numisma.Repo do
  @moduledoc """
  The application repository to store coin data.
  """
  use Ecto.Repo,
    otp_app: :numisma,
    adapter: Ecto.Adapters.Postgres
end
