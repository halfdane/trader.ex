defmodule TraderWeb.OrdersController do
  use TraderWeb, :controller
  require Logger

  def create(conn,  %{"order" => %{"symbol" => symbol,
                                    "buy_price" => buy_price,
                                    "lower_limit" => lower_limit,
                                    "upper_limit" => upper_limit}}) do
    user = conn.assigns.current_user

    Logger.info "new order: #{symbol} #{user.username} #{user.binance_api_key} #{user.binance_api_secret}"

    #Trader.Order.Binance.order_limit_buy(symbol, "100%", buy_price)
    #Trader.Order.Binance.order_limit_sell(symbol, "100%", lower_limit)
    #Trader.Order.Binance.order_limit_sell(symbol, "100%", upper_limit)

    redirect(conn, to: coin_path(conn, :index, symbol))
  end
end
