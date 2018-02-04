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

#    defp current_user(conn, _) do
#      changeset = Auth.change_user(%User{})
#      current_user = Guardian.Plug.current_resource(conn)
#      assign(conn, :current_user, current_user)
#      assign(conn, :changeset, changeset)
#      Logger.info "CURRENT USER: #{inspect conn.assigns.changeset}"
#      conn
#    end
end
