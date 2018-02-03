defmodule Trader.CoinTicker do
  use WebSockex
  require Logger

  def start_link(symbol) do
    url = "wss://stream2.binance.com:9443/ws/#{symbol}@aggTrade"
    WebSockex.start_link("#{url}", __MODULE__, %{symbol: symbol})
  end

  def handle_frame({type, msg}, %{symbol: symbol}=state) do
    Poison.decode!(msg)
      |> to_order
      |> TraderWeb.CoinChannel.update_trade(symbol)
    {:ok, state}
  end

  defp to_order(%{
    "e" => event_type,  # (aggTrade)
    "E" => event_time,
    "s" => symbol,
    "a" => aggregate_trade_id,
    "p" => price_string,
    "q" => quantity_string,
    "f" => _first_trade_id,
    "l" => _last_trade_id,
    "T" => trade_time,
    "m" => market_maker,
    "M" => _api_says_to_ignore
  } = order) do
    %{
      event_type: event_type,
      symbol: symbol,
      price: String.to_float(price_string),
      quantity: String.to_float(quantity_string),
      trade_time: trade_time,
      is_market_maker: market_maker
    }
  end
end
