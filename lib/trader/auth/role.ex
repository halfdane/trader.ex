defmodule Trader.Auth.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias Trader.Auth.Role


  schema "roles" do
    field :admin, :boolean, default: false
    field :name, :string

    has_many :users, Trader.Auth.User

    timestamps()
  end

  @doc false
  def changeset(%Role{} = role, attrs) do
    role
    |> cast(attrs, [:name, :admin])
    |> validate_required([:name, :admin])
  end
end
