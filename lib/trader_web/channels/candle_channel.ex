defmodule TraderWeb.CandleChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub
  require Logger

  def join("candle:" <> symbol, _params, socket) do
    PubSub.subscribe(:notifications, "#{symbol}:candles")
    #PubSub.subscribe(:notifications, "#{symbol}:agg_trades")
    {:ok, socket}
  end

  def handle_info({:candle, candle}, state) do
    #Logger.info("Got a candle for #{candle.symbol}")
    room = "candle:#{candle.symbol}"
    TraderWeb.Endpoint.broadcast(room, "candle_update", candle)
    {:noreply, state}
  end
  def handle_info({:agg_trade, trade}, state) do
    Logger.info("Got an aggTrade for #{trade.symbol}")
    {:noreply, state}
  end
end
