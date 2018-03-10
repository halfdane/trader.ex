defmodule Trader.Signal.OverThreshold do
  use GenServer
  alias Trader.Notify
  alias Trader.Binance.OrderHelper
  require Logger

  def start_link(%{
        symbol: symbol,
        upper_threshold: upper_threshold,
        lower_threshold: lower_threshold,
        binance_auth: binance_auth
      }) do
    GenServer.start_link(
      __MODULE__,
      %{
        symbol: symbol,
        upper_threshold: upper_threshold,
        lower_threshold: lower_threshold,
        binance_auth: binance_auth
      },
      []
    )
  end

  def init(state) do
    Notify.sub_agg_trades(state.symbol)
    {:ok, state}
  end

  def handle_info({:agg_trade, trade}, state) do
    if trade.price > state.upper_threshold || trade.price < state.lower_threshold do
      da_order(state.symbol, state.binance_auth, trade.price)
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  defp da_order(symbol, binance_auth, price) do
    # prepare order and place it
    {:ok, info} = Trader.Binance.ExchangeInfo.get_symbol(symbol)
    user = Trader.Order.Binance.user_info(binance_auth)
    Logger.info("#{inspect(user)}")
    all = Trader.Order.Binance.get_balance(binance_auth, info.quoteAsset)
    valid_lot = OrderHelper.valid_lot(String.to_float(all), info)
    valid_price = OrderHelper.valid_price(price, info)
    Logger.info("Selling #{valid_lot}, #{valid_price}")
    res = Trader.Order.Binance.order_limit_sell(binance_auth, symbol, valid_lot, valid_price)
    Logger.info("#{inspect(res)}")
  end
end
