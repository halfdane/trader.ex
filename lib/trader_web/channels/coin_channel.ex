defmodule TraderWeb.CoinChannel do
  use Phoenix.Channel
  require Logger

  def join("coin:" <> symbol, _params, socket) do
    Logger.info "Someone joined #{"coin:" <> symbol}"
    {:ok, socket}
  end

  def update_trade(trade, symbol) do
    room = "coin:#{symbol.symbol}"
    TraderWeb.Endpoint.broadcast(room, "new_msg", trade)
  end

end
