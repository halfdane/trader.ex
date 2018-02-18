defmodule Trader.Signal.OverThreshold do
    use GenServer
    alias Phoenix.PubSub
    require Logger

    def start_link(%{symbol: symbol, threshold: threshold, api_key: api_key, api_secret: api_secret}) do
        GenServer.start_link(__MODULE__, %{symbol: symbol, threshold: threshold, api_key: api_key, api_secret: api_secret}, [])
    end

    def init(state) do
        PubSub.subscribe(:candle_notifications, state.symbol)
        {:ok, state}
    end

    def handle_info({:candle, candle}, state) do
        Logger.info "new info"
        if candle.high_price > state.threshold do
            Logger.info "#{candle.high_price} > #{state.threshold} That's it! Sending the signal"
            {:stop, :normal, state}
        else
            {:noreply, state}
        end
    end
    
end