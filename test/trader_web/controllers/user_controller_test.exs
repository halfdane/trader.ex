defmodule TraderWeb.UserControllerTest do
  use TraderWeb.ConnCase

  alias Trader.Auth

  @create_attrs %{password: "some password", username: "some username"}
  @update_attrs %{password: "some updated password", username: "some updated username"}
  @invalid_attrs %{password: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Auth.create_user(@create_attrs)
    user
  end

  describe "index" do
    @tag :skip # no admin role yet
    test "lists all users", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "logs in and redirects to show when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs

      assert redirected_to(conn) == user_path(conn, :show)
      assert Guardian.Plug.current_resource(conn)
      conn = get conn, user_path(conn, :show)
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
      [username, password] = conn.assigns.changeset.errors
      assert username == {:username, {"can't be blank", [validation: :required]}}
      assert password == {:password, {"can't be blank", [validation: :required]}}
    end
  end

  describe "edit user" do
    setup [:authenticated]
    test "renders form for editing chosen user", %{conn: conn} do
      conn = get conn, user_path(conn, :edit)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:authenticated]
    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put conn, user_path(conn, :update), user: @update_attrs
      assert redirected_to(conn) == user_path(conn, :show)
      conn = get conn, user_path(conn, :show)
      assert ! (html_response(conn, 200) =~ user.password)
    end

    setup [:authenticated]
    test "renders errors when data is invalid", %{conn: conn} do
      conn = put conn, user_path(conn, :update), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
      [username, password] = conn.assigns.changeset.errors
      assert username == {:username, {"can't be blank", [validation: :required]}}
      assert password == {:password, {"can't be blank", [validation: :required]}}
    end
  end

  describe "delete user" do
    setup [:authenticated]
    test "deletes chosen user and logs out", %{conn: conn} do
      conn = delete conn, user_path(conn, :delete)
      assert redirected_to(conn) == page_path(conn, :index)
      refute Guardian.Plug.current_resource(conn)
    end
  end

  defp authenticated(%{conn: conn}) do
    user = fixture(:user)
    conn = guardian_login(conn, user)
    {:ok, user: user, conn: conn}
  end
end
