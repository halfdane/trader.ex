defmodule TraderWeb.SessionControllerTest do
  use TraderWeb.ConnCase
  alias Trader.TestHelper

  require Logger

  setup do
    {:ok, user_role}  = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, admin_role}  = TestHelper.create_role(%{name: "admin", admin: true})

    {:ok, user} = TestHelper.create_user(user_role, %{username: "test", password: "test"})
    {:ok, admin} = TestHelper.create_user(admin_role, %{username: "admin", password: "admin"})

    {:ok, conn: build_conn(), user: user, admin: admin}
  end

  test "shows the login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Sign in"
  end

  test "creates a new user session for a valid user", %{conn: conn, user: user} do
    conn = post conn, session_path(conn, :create), session: %{username: "test", password: "test"}
    assert Guardian.Plug.current_resource(conn).id == user.id
    refute Guardian.Plug.current_resource(conn, key: :admin)
    assert get_flash(conn, :success) == "Welcome back!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "creates a new admin session for a admin user", %{conn: conn, admin: admin} do
    conn = post conn, session_path(conn, :create), session: %{username: "admin", password: "admin"}
    assert Guardian.Plug.current_resource(conn).id == admin.id
    assert Guardian.Plug.current_resource(conn, key: :admin).id ==  admin.id
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create a session with a bad login", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "test", password: "wrong"}
    refute Guardian.Plug.current_resource(conn)
    refute Guardian.Plug.current_resource(conn, key: :admin)
    assert get_flash(conn, :error) == "Incorrect username or password"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create a session if user does not exist", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "foo", password: "wrong"}
    refute Guardian.Plug.current_resource(conn)
    refute Guardian.Plug.current_resource(conn, key: :admin)
    assert get_flash(conn, :error) == "Incorrect username or password"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "removes session if it is closed", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "test", password: "test"}
    conn = delete conn, session_path(conn, :delete, :ignore)
    refute Guardian.Plug.current_resource(conn)
    refute Guardian.Plug.current_resource(conn, key: :admin)
  end

  test "removes admin session if it is closed", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "admin", password: "admin"}
    assert Guardian.Plug.current_resource(conn).id
    assert Guardian.Plug.current_resource(conn, key: :admin).id
    conn = delete conn, session_path(conn, :delete, :ignore)
    refute Guardian.Plug.current_resource(conn)
    refute Guardian.Plug.current_resource(conn, key: :admin)
  end
end
