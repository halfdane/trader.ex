defmodule TraderWeb.CoinChannel do
  use Phoenix.Channel
  require Logger

  def join("coin:" <> symbol, _params, socket) do
    Logger.info "Someone joined #{"coin:" <> symbol}"
    {:ok, socket}
  end

  def update_trade(trade, symbol) do
    Logger.info "info about #{symbol}: #{inspect(is_binary symbol)}"
    room = "coin:#{String.upcase(symbol, :ascii)}"
    TraderWeb.Endpoint.broadcast(room, "new_msg", trade)
  end

end
