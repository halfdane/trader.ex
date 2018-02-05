defmodule Trader.Auth.CurrentUser do
  import Plug.Conn
  import Guardian.Plug

  alias Trader.Auth
  alias Trader.Auth.User

  require Logger

  def init(opts), do: opts
  def call(conn, _opts) do
    current_user = current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
