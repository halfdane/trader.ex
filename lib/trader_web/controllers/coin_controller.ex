defmodule TraderWeb.CoinController do
  use TraderWeb, :controller

  def index(conn, %{"symbol" => symbol}) do
    render conn, "index.html", symbol: symbol
  end
end
