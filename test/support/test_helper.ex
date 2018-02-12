defmodule Trader.TestHelper do
  alias Trader.Repo
  alias Trader.Auth.User
  alias Trader.Auth.Role
  import Ecto, only: [build_assoc: 2]
  def create_role(%{name: name, admin: admin}) do
    Role.changeset(%Role{}, %{name: name, admin: admin})
    |> Repo.insert
  end
  def create_user(role, %{username: username, password: password}) do
    role
    |> build_assoc(:users)
    |> User.changeset(%{username: username, password: password})
    |> Repo.insert
  end
end
