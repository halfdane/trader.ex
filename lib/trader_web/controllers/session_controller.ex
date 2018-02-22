defmodule TraderWeb.SessionController do
  use TraderWeb, :controller
  alias Trader.Auth
  alias Trader.Auth.User
  alias Trader.Auth.Role

  plug(:scrub_params, "session" when action in ~w(create)a)

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    Auth.authenticate_user(username, password)
    |> login_reply(conn)
  end

  def delete(conn, _) do
    conn
    |> Trader.Auth.Guardian.Plug.sign_out()
    |> Trader.Auth.Guardian.Plug.sign_out(key: :admin)
    |> put_flash(:info, "See you later!")
    |> redirect(to: page_path(conn, :index))
  end

  defp login_reply({:error, error}, conn) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: "/")
  end

  defp login_reply({:ok, %User{role: %Role{admin: admin}} = user}, conn) when admin == true do
    conn
    |> put_flash(:success, "Welcome back!")
    |> Trader.Auth.Guardian.Plug.sign_in(user)
    |> Trader.Auth.Guardian.Plug.sign_in(user, %{}, key: :admin)
    |> redirect(to: "/")
  end

  defp login_reply({:ok, %User{role: %Role{admin: admin}} = user}, conn) when admin == false do
    conn
    |> put_flash(:success, "Welcome back!")
    |> Trader.Auth.Guardian.Plug.sign_in(user)
    |> redirect(to: "/")
  end
end
