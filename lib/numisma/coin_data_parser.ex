defmodule Numisma.CoinDataParser do

  @coin_metadata_fields [
    "@id", "nmo:hasAuthority", "nmo:hasEndDate", "nmo:hasStartDate",
    "nmo:hasRegion", "nmo:hasMint", "nmo:hasLegend", "nmo:hasPortrait",
    "nmo:hasDenomination"
  ]

  @table_map %{
    "nmo:hasDenomination" => :denomination, "nmo:hasRegion" => :region,
    "nmo:hasMint" => :mint, "nmo:hasStartDate" => :start_date,
    "nmo:hasEndDate" => :end_date, "nmo:hasAuthority" => :authority
  }

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

    %{coin_id: coin_id}
  end

  def parse_field(body, fieldname = "nmo:hasLegend") do
    case body do
      [_, obverse_body, reverse_body] ->
        obverse_legend = handle_legend(obverse_body, fieldname)
        reverse_legend = handle_legend(reverse_body, fieldname)
        %{obverse_legend: obverse_legend, reverse_legend: reverse_legend}
      [_] -> %{obverse_legend: nil, reverse_legend: nil}
      [] -> %{obverse_legend: nil, reverse_legend: nil}
    end
  end

  def parse_field(body, _fieldname = "nmo:hasPortrait") do
    case body do
      [_, obverse_body, reverse_body] ->
        obverse_portrait = handle_portrait(obverse_body)
        reverse_portrait = handle_portrait(reverse_body)
        %{obverse_portrait: obverse_portrait, reverse_portrait: reverse_portrait}
      [_] -> %{obverse_portrait: nil, reverse_portrait: nil}
      [] -> %{obverse_portrait: nil, reverse_portrait: nil}
    end
  end

  def parse_field(body, fieldname) do

    coin_field = body
     |> List.first
     |> then(fn field ->
      case Map.get(field, fieldname) do
        nil -> nil
        _ -> process_metadata_field(field, fieldname)
      end
     end
     )

     %{@table_map[fieldname] => coin_field}
  end

  # TODO: Fix this. String.split() is not working
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
          _ ->
            field
              |> List.first
              |> then(fn field ->
                case Map.get(field, "@id") do
                  nil -> nil
                  _ -> field |> Map.get("@id") |> String.split("/") |> List.last
                end
              end)
        end
      end)

  end

  def handle_legend(legend, legend_name) do
    legend
      |> then(fn field ->
        case Map.get(field, legend_name) do
          nil -> nil
          _ -> Map.get(field, legend_name) |> List.last |> Map.get("@value")
        end
      end)
  end

  def handle_portrait(portrait) do
    portrait
      |> then(fn field ->

        portrait_field = field |> Map.get("nmo:hasPortrait")

        case portrait_field do
          nil -> nil
          _ -> portrait_field
          |> List.first
          |> Map.get("@id")
          |> then(fn portrait_field ->
            case portrait_field do
              nil -> nil
              _ -> portrait_field |> String.split("/") |> List.last
            end
          end)
        end
      end)
    end

end
