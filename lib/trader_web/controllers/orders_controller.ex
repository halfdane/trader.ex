defmodule TraderWeb.OrdersController do
  use TraderWeb, :controller
  alias Trader.Binance.OrderHelper
  require Logger

  def create(conn,  %{"order" => %{"symbol" => symbol,
                                    "buy_price" => buy_price,
                                    "lower_limit" => lower_limit,
                                    "upper_limit" => upper_limit}}) do
    user = conn.assigns.current_user
    binance_access = %{key: user.binance_api_key, secret: user.binance_api_secret}

    {:ok, info} = Trader.Binance.ExchangeInfo.get_symbol(symbol)
    all = Trader.Order.Binance.get_balance(binance_access, info.baseAsset)

    valid_price = OrderHelper.valid_price(String.to_float(buy_price), info)
    valid_upper_limit = OrderHelper.valid_price(String.to_float(upper_limit), info)
    valid_lower_limit = OrderHelper.valid_price(String.to_float(lower_limit), info)

    valid_lot = OrderHelper.valid_lot(String.to_float(all), info)

    Trader.Order.Binance.order_limit_buy(binance_access, symbol, valid_lot, valid_price) |> log
    Trader.Order.Binance.order_limit_sell(binance_access, symbol, valid_lot, valid_lower_limit) |> log
    Trader.Order.Binance.order_limit_sell(binance_access, symbol, valid_lot, valid_upper_limit) |> log

    redirect(conn, to: coin_path(conn, :index, symbol))
  end

  defp log(a) do
    Logger.info "#{inspect a}"
  end
end
