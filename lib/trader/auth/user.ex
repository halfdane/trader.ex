defmodule Trader.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Trader.Auth.User
  alias Comeonin.Bcrypt


  schema "users" do
    field :password, :string
    field :username, :string
    field :binance_api_key, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
      |> cast(attrs, [:username, :password, :binance_api_key])
      |> validate_required([:username, :password])
      |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Bcrypt.hashpwsalt(password))
  end
  defp put_pass_hash(changeset), do: changeset
end
