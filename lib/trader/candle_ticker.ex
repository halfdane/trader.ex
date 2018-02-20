defmodule Trader.CandleTicker do
  use WebSockex
  require Logger
  alias Phoenix.PubSub

  def start_link(symbol) do
    Logger.info "Starting candle ticker for #{symbol}"
    url = "wss://stream2.binance.com:9443/ws/#{String.downcase(symbol)}@kline_1m"
    Logger.debug "Ticker streams from #{url}"
    WebSockex.start_link(url, __MODULE__, %{symbol: symbol}, name: via_tuple(symbol))
  end

  defp via_tuple(symbol) do
    {:via, :gproc, {:n, :l, {:symbol, symbol}}}
  end

  def handle_frame({_type, msg}, %{symbol: symbol}=state) do
    candle = Poison.decode!(msg)
      |> to_candle
      
    PubSub.broadcast(:notifications, "#{symbol}:candles", {:candle, candle})
      
    {:ok, state}
  end

  defp to_candle(%{
    "e" => event_type,  # ("kline")
    "E" => event_time,
    "s" => _symbol1,
    "k" => %{
      "t" => _kline_start_time,
      "T" => _kline_close_time,
      "s" => symbol,
      "i" => _interval,
      "f" => _first_trade_id,
      "L" => _last_trade_id,
      "o" => open_price,
      "c" => close_price,
      "h" => high_price,
      "l" => low_price,
      "v" => _base_asset_volume,
      "n" => _number_of_trades,
      "x" => is_kline_closed,
      "q" => _quote_asset_volume,
      "V" => _taker_buy_base_volume,
      "Q" => _taker_buy_quote_volume,
      "B" => _docs_say_to_ignore
    }}) do
      %{
        event_type: event_type,
        symbol: symbol,
        open_price: String.to_float(open_price),
        close_price: String.to_float(close_price),
        high_price: String.to_float(high_price),
        low_price: String.to_float(low_price),
        event_time: event_time,
        is_kline_closed: is_kline_closed
      }
    end

end
