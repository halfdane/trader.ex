defmodule Trader.Binance.ExchangeInfo do
  use GenServer
  # Client
  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_symbol(symbol) do
    GenServer.call(__MODULE__, {:get_symbol, symbol})
  end

  def get_symbols() do
    GenServer.call(__MODULE__, :get_symbols)
  end

  # Server
  def init(state), do: {:ok, state}

  def handle_call({:get_symbol, symbol}, _from, state) do
    {:reply, :ok, state}
  end


end
