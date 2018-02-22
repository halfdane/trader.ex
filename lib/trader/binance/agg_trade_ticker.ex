defmodule Trader.Binance.AggTradeTicker do
  use WebSockex
  require Logger
  alias Trader.Notify

  def start_link(symbol) do
    url = "wss://stream2.binance.com:9443/ws/#{String.downcase(symbol)}@aggTrade"
    WebSockex.start_link(url, __MODULE__, %{symbol: symbol}, name: via_tuple(symbol))
    Logger.info("Started aggTrade ticker for #{symbol} at #{url}")
  end

  defp via_tuple(symbol) do
    {:via, :gproc, {:n, :l, {:symbol, symbol, __MODULE__}}}
  end

  def handle_frame({_type, msg}, %{symbol: symbol} = state) do
    agg_trade =
      Poison.decode!(msg)
      |> to_agg_trade

    Notify.agg_trade(agg_trade)

    {:ok, state}
  end

  defp to_agg_trade(%{
        # aggTrade
        "e" => event_type,
        "E" => event_time,
        "s" => symbol,
        "a" => _aggregate_trade_ID,
        "p" => price,
        "q" => quantity,
        "f" => _first_trade_ID,
        "l" => _last_trade_ID,
        "T" => trade_time,
        "m" => is_the_buyer_the_market_maker,
        "M" => _ignore
       }) do
    %{
      event_type: event_type,
      event_time: event_time,
      trade_time: trade_time,
      symbol: symbol,
      price: String.to_float(price),
      quantity: String.to_float(quantity),
      is_market_maker: is_the_buyer_the_market_maker
    }
  end
end
