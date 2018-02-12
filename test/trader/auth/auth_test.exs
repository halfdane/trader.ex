defmodule Trader.AuthTest do
  use Trader.DataCase

  alias Trader.Auth
  alias Trader.TestHelper

  describe "users" do
    alias Trader.Auth.User

    @valid_attrs %{password: "some password", username: "some username"}
    @update_attrs %{password: "some updated password", username: "some updated username"}
    @invalid_attrs %{password: nil, username: nil}

    defp with_role(attrs, role) do
      Map.put(attrs, :role_id, role.id)
    end

    def user_fixture(role) do
      {:ok, user} =
        with_role(@valid_attrs, role)
        |> Auth.create_user()
      user
    end

    setup do
      {:ok, user_role}  = TestHelper.create_role(%{name: "user", admin: false})
      {:ok, user_role: user_role}
    end

    test "list_users/0 returns all users", %{user_role: user_role} do
      user = user_fixture(user_role)
      assert Auth.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id", %{user_role: user_role} do
      user = user_fixture(user_role)
      assert Auth.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user", %{user_role: user_role} do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs|>with_role(user_role))
      assert user.username == "some username"
      assert Comeonin.Bcrypt.checkpw(@valid_attrs.password, user.password)
    end

    test "create_user/1 with invalid data returns error changeset", %{user_role: user_role} do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs|>with_role(user_role))
    end

    test "update_user/2 with valid data updates the user", %{user_role: user_role} do
      user = user_fixture(user_role)
      assert {:ok, user} = Auth.update_user(user, @update_attrs|>with_role(user_role))
      assert %User{} = user
      assert Comeonin.Bcrypt.checkpw(@update_attrs.password, user.password)
      assert user.username == "some updated username"
      assert user.role_id == user_role.id
    end

    test "update_user/2 with invalid data returns error changeset", %{user_role: user_role} do
      user = user_fixture(user_role)
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs|>with_role(user_role))
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user", %{user_role: user_role} do
      user = user_fixture(user_role)
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset", %{user_role: user_role} do
      user = user_fixture(user_role)
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end
  end
end
