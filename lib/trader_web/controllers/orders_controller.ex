defmodule TraderWeb.OrdersController do
  use TraderWeb, :controller
  require Logger

  def create(conn,  %{"order" => %{"symbol" => symbol,
                                    "buy_price" => buy_price,
                                    "lower_limit" => lower_limit,
                                    "upper_limit" => upper_limit}}) do
    user = conn.assigns.current_user
    binance_access = %{key: user.binance_api_key, secret: user.binance_api_secret}

    all = "0.035"
    upper_limit = "0.103515"
    #Trader.Order.Binance.order_limit_buy(binance_access, symbol, all, buy_price) |> log
    Trader.Order.Binance.order_limit_sell(binance_access, symbol, all, upper_limit) |> log
    #Trader.Order.Binance.order_limit_sell(binance_access, symbol, all, upper_limit) |> log

    redirect(conn, to: coin_path(conn, :index, symbol))
  end

  defp log(a) do
    Logger.info "#{inspect a}"
  end
end
