defmodule TraderWeb.CoinChannel do
  use Phoenix.Channel
  require Logger

  def join("coin:lobby", _message, socket) do
    send self(), :update
    {:ok, socket}
  end
  def join("coin:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:update, socket), do: push_current_info(socket)

  def push_current_info(socket) do
    Process.send_after(self(), :update, 1000)
    order = Trader.Worker.get()
    push socket, "new_msg", %{content: order}
    {:noreply, socket}
  end

end
