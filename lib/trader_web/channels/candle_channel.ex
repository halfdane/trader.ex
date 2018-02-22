defmodule TraderWeb.CandleChannel do
  use Phoenix.Channel
  alias Trader.Notify
  require Logger

  def join("candle:" <> symbol, _params, socket) do
    Notify.sub_candles(symbol)
    Notify.sub_agg_trades(symbol)
    {:ok, socket}
  end

  def handle_info({:candle, candle}, state) do
    # Logger.info("Got a candle for #{candle.symbol}")
    room = "candle:#{candle.symbol}"
    TraderWeb.Endpoint.broadcast(room, "candle_update", candle)
    {:noreply, state}
  end

  def handle_info({:agg_trade, trade}, state) do
    Logger.info("Got an aggTrade for #{trade.symbol}")
    {:noreply, state}
  end
end
