defmodule Trader.TestHelper do
  alias Trader.Repo
  alias Trader.Auth.User
  alias Trader.Auth.Role
  import Ecto, only: [build_assoc: 2]

  def create_role(%{name: name, admin: admin}) do
    Role.changeset(%Role{}, %{name: name, admin: admin})
    |> Repo.insert()
  end

  def create_user(role, %{username: username, password: password}) do
    {:ok, user} =
      role
      |> build_assoc(:users)
      |> User.changeset(%{username: username, password: password})
      |> Repo.insert()

    # provide plaintest password in tests
    {:ok, %{user | password: password}}
  end
end
