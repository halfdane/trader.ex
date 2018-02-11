defmodule Trader.Binance.ExchangeInfoTest do
  use ExUnit.Case

  alias Trader.Binance.ExchangeInfo
  alias Trader.Testdata

  setup do
    {:ok, _} = ExchangeInfo.start_link(Testdata.binance_exchange_info)
    :ok
  end

  test "get symbol info" do
    {:ok, info} = ExchangeInfo.get_symbol("ETHBTC")
    assert info.symbol == "ETHBTC"
    assert info.status == "TRADING"
    assert info.baseAsset == "ETH"
  end

  test "get all symbol infos" do
    {:ok, symbols} = ExchangeInfo.get_symbols()
    symbol_names = symbols |> Enum.map(&(&1.symbol))
    assert symbol_names == ["ETHBTC", "LTCBTC"]
  end

end
