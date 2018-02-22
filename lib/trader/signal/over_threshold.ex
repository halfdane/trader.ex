defmodule Trader.Signal.OverThreshold do
  use GenServer
  alias Trader.Notify
  require Logger

  def start_link(%{symbol: symbol, threshold: threshold, api_key: api_key, api_secret: api_secret}) do
    GenServer.start_link(
      __MODULE__,
      %{symbol: symbol, threshold: threshold, api_key: api_key, api_secret: api_secret},
      []
    )
  end

  def init(state) do
    Notify.sub_candles(state.symbol)
    {:ok, state}
  end

  def handle_info({:candle, candle}, state) do
    if candle.high_price > state.threshold do
      Notify.signal(state)
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end
end
