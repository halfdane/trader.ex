defmodule Trader.Binance.ExchangeInfoHelper do
  def parse_exchange_info(exchange_info_response) do
    Poison.decode!(exchange_info_response)
    |> to_atom_map
  end

  def get_symbol_info(exchange_info, symbol) do
    exchange_info.symbols
    |> Enum.filter(&(&1.symbol == symbol))
    |> List.first()
  end

  def reduce_to(exchange_info, supported_symbols) do
    filtered_symbols =
      exchange_info.symbols
      |> Enum.filter(&(&1.symbol in supported_symbols))

    Map.put(exchange_info, :symbols, filtered_symbols)
  end

  def get_price_filter(exchange_info, symbol),
    do: get_filter_info(exchange_info, symbol, "PRICE_FILTER")

  def get_lot_size(exchange_info, symbol), do: get_filter_info(exchange_info, symbol, "LOT_SIZE")

  def get_min_notional(exchange_info, symbol),
    do: get_filter_info(exchange_info, symbol, "MIN_NOTIONAL")

  def get_price_filter(symbol_info), do: from_filters(symbol_info, "PRICE_FILTER")
  def get_lot_size(symbol_info), do: from_filters(symbol_info, "LOT_SIZE")
  def get_min_notional(symbol_info), do: from_filters(symbol_info, "MIN_NOTIONAL")

  defp get_filter_info(exchange_info, symbol, filter_name) do
    exchange_info
    |> get_symbol_info(symbol)
    |> from_filters(filter_name)
  end

  defp from_filters(symbol_info, filter_name) do
    symbol_info
    |> Map.get(:filters)
    |> Enum.filter(&(&1.filterType == filter_name))
    |> List.first()
  end

  defp to_atom_map(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, result ->
      key_atom = String.to_atom(key)
      value_atom = to_atom_map(value)
      Map.put(result, key_atom, pure_numbers(key_atom, value_atom))
    end)
  end

  defp to_atom_map(list) when is_list(list), do: Enum.map(list, &to_atom_map/1)
  defp to_atom_map(value), do: value

  defp pure_numbers(key, value)
       when key in [:tickSize, :minPrice, :maxPrice, :minQty, :maxQty, :stepSize, :minNotional],
       do: String.to_float(value)

  defp pure_numbers(_, value), do: value
end
