defmodule Numisma.CoinDataParser do

  @coin_metadata_fields [
    "@id", "nmo:hasAuthority", "nmo:hasEndDate", "nmo:hasStartDate",
    "nmo:hasRegion", "nmo:hasMint", "nmo:hasLegend", "nmo:hasPortrait"
  ]

  def parse_coin(body) do
    for field_name <- @coin_metadata_fields do
      parse_field(body, field_name)
    end |>
    Enum.reduce(%{}, fn field, acc -> Map.merge(field, acc) end)
  end

  def parse_field(body, fieldname = "@id") do
    coin_id =
      body
      |> List.first
      |> Map.get(fieldname)
      |> String.split("/")
      |> List.last

    %{id: coin_id}
  end

  def parse_field(body, fieldname = "nmo:hasLegend") do

    [_, obverse_body, reverse_body] = body

    obverse_legend =
      obverse_body
      |> then(fn field ->
        case field do
          nil -> nil
          _ -> Map.get(field, fieldname) |> List.first |> Map.get("@value")
        end
      end)

    reverse_legend =
      reverse_body
      |> then(fn field ->
        case field do
          nil -> nil
          _ -> Map.get(field, fieldname) |> List.last |> Map.get("@value")
        end
      end)

    %{obverse_legend: obverse_legend, reverse_legend: reverse_legend}
  end

  def parse_field(body, fieldname = "nmo:hasPortrait") do

    [_, obverse_body, reverse_body] = body

    obverse_portrait =
      obverse_body
      |> Map.get(fieldname)
      |> then(fn field ->
         case field do
           nil -> nil
           _ -> field |> List.first |> Map.get("@id") |> String.split("/") |> List.last
         end
      end)

    reverse_portrait =
      reverse_body
      |> Map.get(fieldname)
      |> then(fn field ->
         case field do
           nil -> nil
           _ -> field |> List.last |> Map.get("@id") |> String.split("/") |> List.last
         end
      end)

    %{obverse_portrait: obverse_portrait, reverse_portrait: reverse_portrait}
  end

  def parse_field(body, fieldname) do

    fieldname_atom = fieldname
      |> String.split(":")
      |> List.last
      |> String.downcase
      |> String.to_atom

    coin_field = body
     |> List.first
     |> then(fn field ->
      case Map.get(field, fieldname) do
        nil -> nil
        _ -> process_metadata_field(field, fieldname)
      end
     end
     )

     %{fieldname_atom => coin_field}
  end

  def process_metadata_field(metadata, metadata_field = "nmo:hasStartDate") do
    metadata
      |> Map.get(metadata_field)
      |> then(fn field ->
        case field do
          nil -> nil
          _ -> field |> List.first |> Map.get("@value")
        end
      end)
  end

  def process_metadata_field(metadata, metadata_field = "nmo:hasEndDate") do
    metadata
      |> Map.get(metadata_field)
      |> then(fn field ->
        case field do
          nil -> nil
          _ -> field |> List.first |> Map.get("@value")
        end
      end)
  end

  def process_metadata_field(metadata, metadata_field) do
    metadata
      |> Map.get(metadata_field)
      |> then(fn field ->
        case field do
          nil -> nil
          _ -> field |> List.first |> Map.get("@id") |> String.split("/") |> List.last
        end
      end)

  end


end
