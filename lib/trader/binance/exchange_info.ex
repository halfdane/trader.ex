defmodule Trader.Binance.ExchangeInfo do
  use GenServer
  alias Trader.Binance.ExchangeInfoHelper
  require Logger

  # Client
  def start_link(exchange_info_string, name \\ __MODULE__) do
    GenServer  .start_link(__MODULE__, exchange_info_string, name: name)
  end

  def get_symbol(symbol, name \\ __MODULE__) do
    GenServer.call(name, {:get_symbol, symbol})
  end

  def get_symbols(name \\ __MODULE__) do
    GenServer.call(name, :get_symbols)
  end

  # Server
  def init(state) do
    Logger.info "Parsing Exchange info"
    supported_symbols = Application.get_env(:trader, Trader.SupportedSymbols)[:symbols]
    info = state
      |> ExchangeInfoHelper.parse_exchange_info
      |> ExchangeInfoHelper.reduce_to(supported_symbols)
    Logger.debug "DONE Parsing exchange info"
     {:ok, info}
   end

  def handle_call({:get_symbol, symbol}, _from, state) do
    symbol_info = ExchangeInfoHelper.get_symbol_info(state, symbol)
    {:reply, {:ok, symbol_info}, state}
  end

  def handle_call(:get_symbols, _from, state) do
    {:reply, {:ok, state.symbols}, state}
  end

end
