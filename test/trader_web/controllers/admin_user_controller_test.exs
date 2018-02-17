defmodule TraderWeb.AdminUserControllerTest do
  use TraderWeb.ConnCase

  alias Trader.TestHelper
  alias Trader.Repo
  alias Trader.Auth.User

  @create_attrs %{password: "some password", username: "some username"}
  @update_attrs %{password: "some updated password", username: "some updated username"}
  @invalid_attrs %{password: nil, username: nil}

  setup do
    {:ok, user_role}  = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, admin_role}  = TestHelper.create_role(%{name: "admin", admin: true})

    {:ok, user} = TestHelper.create_user(user_role, %{username: "test", password: "test"})
    {:ok, admin} = TestHelper.create_user(admin_role, %{username: "admin", password: "admin"})

    {:ok, conn: build_conn(), user: user, admin: admin, user_role: user_role, admin_role: admin_role}
  end

  describe "index" do
    test "prohibit listing of users if not logged in", %{conn: conn} do
      conn = get conn, admin_user_path(conn, :index)
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "prohibit listing of users for user", %{conn: conn, user: user} do
      conn = conn
        |> guardian_login(user)
        |> get(admin_user_path(conn, :index))
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "allow listing of users for admin", %{conn: conn, admin: admin} do
      conn = conn
        |> guardian_login(admin)
        |> get(admin_user_path(conn, :index))
      
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "prohibit form rendering if not logged in", %{conn: conn} do
      conn = get conn, admin_user_path(conn, :new)
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "prohibit form rendering for users", %{conn: conn, user: user} do
      conn = conn
        |> guardian_login(user)
        |> get(admin_user_path(conn, :new))
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "renders form for admin", %{conn: conn, admin: admin} do
      conn = conn
        |> guardian_login(admin)
        |> get(admin_user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "prohibit post when data is valid for anonymous", %{conn: conn, user_role: user_role} do
      conn = post conn, admin_user_path(conn, :create), user: with_role(@create_attrs, user_role)
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "prohibit post when data is valid for normal users", %{conn: conn, user_role: user_role, user: user} do
      conn = conn
        |> guardian_login(user)
        |> post(admin_user_path(conn, :create), user: with_role(@create_attrs, user_role))
      assert html_response(conn, 401) =~ "Unauthorized access"
    end


    test "create user when data is valid for admin", %{conn: conn, user_role: user_role, admin: admin} do
      conn = conn
        |> guardian_login(admin)
        |> post(admin_user_path(conn, :create), user: with_role(@create_attrs, user_role))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == admin_user_path(conn, :show, id)
      assert Guardian.Plug.current_resource(conn)
      conn = get conn, admin_user_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid for admin user", %{conn: conn, user_role: user_role, admin: admin} do
      conn = conn
        |> guardian_login(admin)
        |> post(admin_user_path(conn, :create), user: with_role(@invalid_attrs, user_role))
      assert html_response(conn, 200) =~ "New User"
      [username, password] = conn.assigns.changeset.errors
      assert username == {:username, {"can't be blank", [validation: :required]}}
      assert password == {:password, {"can't be blank", [validation: :required]}}
    end
  end

  
  describe "edit user" do
    test "prohibits access to form for editing chosen user if not logged in", %{conn: conn, user: user} do
      conn = get conn, admin_user_path(conn, :edit, user.id)
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "prohibits access to form for editing chosen user for normal user", %{conn: conn, user: user} do
      conn = conn
        |> guardian_login(user)
        |> get(admin_user_path(conn, :edit, user.id))
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "renders form for editing chosen user for admin", %{conn: conn, user: user, admin: admin} do
      conn = conn
        |> guardian_login(admin)
        |> get(admin_user_path(conn, :edit, user.id))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    test "prohibits update when not logged in ", %{conn: conn, user: user} do
      conn = put conn, admin_user_path(conn, :update, user.id), user: @update_attrs
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "prohibits update when normal user ", %{conn: conn, user: user} do
      conn = conn
        |> guardian_login(user)
        |> put(admin_user_path(conn, :update, user.id), user: @update_attrs)
        assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "redirects when data is valid when logged in as admin", %{conn: conn, user: user, admin: admin} do
      conn = conn
        |> guardian_login(admin)
        |> put(admin_user_path(conn, :update, user.id), user: @update_attrs)
      assert redirected_to(conn) == admin_user_path(conn, :show, user.id)
      conn = get conn, admin_user_path(conn, :show, user.id)
      assert ! (html_response(conn, 200) =~ user.password)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user, admin: admin} do
      conn = conn
        |> guardian_login(admin)
        |> put(admin_user_path(conn, :update, user.id), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
      [username, password] = conn.assigns.changeset.errors
      assert username == {:username, {"can't be blank", [validation: :required]}}
      assert password == {:password, {"can't be blank", [validation: :required]}}
    end
  end

  describe "delete user" do
    test "prohibits delete of chosen user when not logged in", %{conn: conn, user: user} do
      conn = delete conn, admin_user_path(conn, :delete, user.id)
      assert html_response(conn, 401) =~ "Unauthorized access"
    end

    test "prohibits delete of chosen user when normal user login", %{conn: conn, user: user} do
      conn = conn
        |> guardian_login(user)
        |> delete(admin_user_path(conn, :delete, user.id))
      assert html_response(conn, 401) =~ "Unauthorized access"
      assert Repo.get(User, user.id)
    end

    test "deletes chosen user when admin", %{conn: conn, user: user, admin: admin} do
      conn = conn
        |> guardian_login(admin)
        |> delete(admin_user_path(conn, :delete, user.id))
      assert redirected_to(conn) == admin_user_path(conn, :index)
      refute Repo.get(User, user.id)
    end
  end

  defp with_role(attrs, role) do
    Map.put(attrs, :role_id, role.id)
  end
end
