defmodule Numisma.OCREAPI do

  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://numismatics.org/ocre"
  plug Tesla.Middleware.Headers, [{"User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/109.0"}]
  plug Tesla.Middleware.FormUrlencoded

  @coins_per_page 20
  @num_coins 41703

  def define_coins_per_page, do: @coins_per_page

  def call_ocre_api(coin_id) do
    case get("id/" <> coin_id <> ".jsonld") do
      {:ok, %{body: body, status: 200}} ->
        {:ok, body |> Jason.decode! |> Map.get("@graph")} # Directly Extracting metadata
      {:ok, %{status: 404}} ->
        {:error, coin_id}
      {:error, :timeout} ->
        {:error, "Connection timed out"}
      {:error, :closed} ->
        {:error, "Connection to server closed"}
    end
  end

  def paginate_requests do

    num_pages = Float.ceil(@num_coins / @coins_per_page) |> Kernel.trunc

    requests = for page <- 0..num_pages do

      if page * 20 > @num_coins do
        nil
      else
        "http://numismatics.org/ocre/results?q=&start=#{page * @coins_per_page}"
      end
    end

    requests
  end

end
