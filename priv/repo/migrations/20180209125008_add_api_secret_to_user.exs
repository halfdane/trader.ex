defmodule Trader.Repo.Migrations.AddApiSecretToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :binance_api_secret, :string
    end
  end
end
