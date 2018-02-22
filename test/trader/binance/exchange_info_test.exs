defmodule Trader.Binance.ExchangeInfoTest do
  use ExUnit.Case, async: false

  alias Trader.Binance.ExchangeInfo
  alias Trader.Testdata

  test "get symbol info" do
    ExchangeInfo.start_link(Testdata.binance_exchange_info(), :test)
    {:ok, info} = ExchangeInfo.get_symbol("ETHBTC", :test)
    assert info.symbol == "ETHBTC"
    assert info.status == "TRADING"
    assert info.baseAsset == "ETH"
  end

  test "get all symbol infos" do
    ExchangeInfo.start_link(Testdata.binance_exchange_info(), :test)
    {:ok, symbols} = ExchangeInfo.get_symbols(:test)
    symbol_names = symbols |> Enum.map(& &1.symbol)
    assert symbol_names == ["ETHBTC", "LTCBTC"]
  end
end
