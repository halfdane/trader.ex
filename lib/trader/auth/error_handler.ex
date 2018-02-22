defmodule Trader.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> Phoenix.Controller.render(TraderWeb.ErrorView, "401.html")
  end
end
