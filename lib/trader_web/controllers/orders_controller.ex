defmodule TraderWeb.OrdersController do
  use TraderWeb, :controller
  require Logger

  def create(conn,  %{"order" => %{"symbol" => symbol,
                                    "buy_price" => buy_price,
                                    "lower_limit" => lower_limit,
                                    "upper_limit" => upper_limit}}) do
    Logger.info "new order: #{symbol} min #{lower_limit} max #{upper_limit}"

    Trader.Order.Binance.order_limit_buy(symbol, "100%", buy_price)
    Trader.Order.Binance.order_limit_sell(symbol, "100%", lower_limit)
    Trader.Order.Binance.order_limit_sell(symbol, "100%", upper_limit)

    redirect(conn, to: page_path(conn, :index))
  end
end
