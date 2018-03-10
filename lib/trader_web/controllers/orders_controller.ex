defmodule TraderWeb.OrdersController do
  use TraderWeb, :controller
  alias Trader.Binance.OrderHelper
  require Logger

  def create(conn, %{"order" => %{"symbol" => symbol, "buy_price" => price}}) do
    # create access-info thingie from user
    user = conn.assigns.current_user

    binance_auth = %{
      key: user.binance_api_key,
      secret: user.binance_api_secret
    }

    # prepare order and place it
    {:ok, info} = Trader.Binance.ExchangeInfo.get_symbol(symbol)
    all = Trader.Order.Binance.get_balance(binance_auth, info.baseAsset)
    valid_lot = OrderHelper.valid_lot(String.to_float(all), info)
    valid_price = OrderHelper.valid_price(String.to_float(price), info)
    Logger.info("Buying #{valid_lot}, #{valid_price}")
    res = Trader.Order.Binance.order_limit_buy(binance_auth, symbol, valid_lot, valid_price)
    Logger.info("#{inspect(res)}")

    # if price rises or falls, sell it
    Trader.Signal.OverThreshold.start_link(%{
      symbol: symbol,
      upper_threshold: String.to_float(price),
      lower_threshold: String.to_float(price),
      binance_auth: binance_auth
    })

    redirect(conn, to: coin_path(conn, :index, symbol))
  end
end
