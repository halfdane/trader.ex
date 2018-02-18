defmodule TraderWeb.CandleChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub
  require Logger

  def join("candle:" <> symbol, _params, socket) do
    PubSub.subscribe(:candle_notifications, symbol)
    {:ok, socket}
  end

  def handle_info({:candle, candle}, state) do
    room = "candle:#{candle.symbol}"
    TraderWeb.Endpoint.broadcast(room, "candle_update", candle)
    {:noreply, state}
  end
end
