defmodule TraderWeb.UserControllerTest do
  use TraderWeb.ConnCase

  alias Trader.TestHelper

  @create_attrs %{password: "some password", username: "some username"}
  @update_attrs %{password: "some updated password", username: "some updated username"}
  @invalid_attrs %{password: nil, username: nil}

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    setup [:roles]

    test "logs in and redirects to show when data is valid", %{conn: conn, user_role: user_role} do
      conn = post(conn, user_path(conn, :create), user: with_role(@create_attrs, user_role))

      assert redirected_to(conn) == user_path(conn, :show)
      assert Guardian.Plug.current_resource(conn)
      conn = get(conn, user_path(conn, :show))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn, user_role: user_role} do
      conn = post(conn, user_path(conn, :create), user: with_role(@invalid_attrs, user_role))
      assert html_response(conn, 200) =~ "New User"
      [username, password] = conn.assigns.changeset.errors
      assert username == {:username, {"can't be blank", [validation: :required]}}
      assert password == {:password, {"can't be blank", [validation: :required]}}
    end
  end

  describe "edit user" do
    setup [:roles, :authenticated]

    test "renders form for editing chosen user", %{conn: conn} do
      conn = get(conn, user_path(conn, :edit))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:roles, :authenticated]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, user_path(conn, :update), user: @update_attrs)
      assert redirected_to(conn) == user_path(conn, :show)
      conn = get(conn, user_path(conn, :show))
      assert !(html_response(conn, 200) =~ user.password)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put(conn, user_path(conn, :update), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
      [username, password] = conn.assigns.changeset.errors
      assert username == {:username, {"can't be blank", [validation: :required]}}
      assert password == {:password, {"can't be blank", [validation: :required]}}
    end
  end

  describe "delete user" do
    setup [:roles, :authenticated]

    test "deletes chosen user and logs out", %{conn: conn} do
      conn = delete(conn, user_path(conn, :delete))
      assert redirected_to(conn) == page_path(conn, :index)
      refute Guardian.Plug.current_resource(conn)
    end
  end

  defp with_role(attrs, role) do
    Map.put(attrs, :role_id, role.id)
  end

  defp roles(_) do
    {:ok, user_role} = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, admin_role} = TestHelper.create_role(%{name: "admin", admin: true})
    {:ok, user_role: user_role, admin_role: admin_role}
  end

  defp authenticated(%{conn: conn, user_role: user_role}) do
    {:ok, user} = TestHelper.create_user(user_role, @create_attrs)
    conn = guardian_login(conn, user)
    {:ok, user: user, conn: conn}
  end
end
