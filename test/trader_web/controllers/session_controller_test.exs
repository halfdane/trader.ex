defmodule TraderWeb.SessionControllerTest do
  use TraderWeb.ConnCase
  alias Trader.Auth.User

  require Logger

  setup do
    User.changeset(%User{}, %{username: "test", password: "test"})
    |> Trader.Repo.insert
    {:ok, conn: build_conn()}
  end

  test "shows the login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Sign in"
  end

  test "creates a new user session for a valid user", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "test", password: "test"}
    assert Guardian.Plug.current_resource(conn)
    assert get_flash(conn, :success) == "Welcome back!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create a session with a bad login", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "test", password: "wrong"}
    refute Guardian.Plug.current_resource(conn)
    assert get_flash(conn, :error) == "Incorrect username or password"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create a session if user does not exist", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "foo", password: "wrong"}
    refute Guardian.Plug.current_resource(conn)
    assert get_flash(conn, :error) == "Incorrect username or password"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "removes session if it is closed", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "test", password: "test"}
    conn = delete conn, session_path(conn, :delete, :ignore)
    refute Guardian.Plug.current_resource(conn)
  end
end
