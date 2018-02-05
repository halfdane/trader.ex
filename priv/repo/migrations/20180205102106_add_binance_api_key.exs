defmodule Trader.Repo.Migrations.AddBinanceApiKey do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :binance_api_key, :string
    end
  end
end
