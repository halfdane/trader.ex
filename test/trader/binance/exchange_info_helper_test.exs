defmodule Trader.Binance.ExchangeInfoHelperTest do
  use ExUnit.Case

  alias Trader.Binance.ExchangeInfoHelper
  alias Trader.Testdata

  setup do
    parsed = ExchangeInfoHelper.parse_exchange_info(Testdata.binance_exchange_info)
    {:ok, exchange_info: parsed}
  end

  test "parse exchange info response", %{exchange_info: info} do
    ethbtc = ExchangeInfoHelper.get_symbol_info(info, "ETHBTC")
    assert ethbtc.symbol == "ETHBTC"
    assert ethbtc.status == "TRADING"
    assert ethbtc.baseAsset == "ETH"
    assert ethbtc.quoteAsset == "BTC"
    assert ethbtc.baseAssetPrecision == 8
    assert ethbtc.quotePrecision == 8
    assert ethbtc.icebergAllowed == true
  end

  test "get price filter", %{exchange_info: info} do
    ethbtc_filter = ExchangeInfoHelper.get_price_filter(info, "ETHBTC")
    assert ethbtc_filter.tickSize == 0.00000100
    assert ethbtc_filter.minPrice == 0.00000100
    assert ethbtc_filter.maxPrice == 100000.00000000
  end

  test "get price filter from symbol_info", %{exchange_info: info} do
    symbol_info = ExchangeInfoHelper.get_symbol_info(info, "ETHBTC")
    ethbtc_filter = ExchangeInfoHelper.get_price_filter(symbol_info)
    assert ethbtc_filter.tickSize == 0.00000100
    assert ethbtc_filter.minPrice == 0.00000100
    assert ethbtc_filter.maxPrice == 100000.00000000
  end

  test "get lot size", %{exchange_info: info} do
    ethbtc_lot = ExchangeInfoHelper.get_lot_size(info, "ETHBTC")
    assert ethbtc_lot.minQty == 0.00100000
    assert ethbtc_lot.maxQty == 100000.00000000
    assert ethbtc_lot.stepSize == 0.00100000
  end

  test "get lot_size from symbol_info", %{exchange_info: info} do
    symbol_info = ExchangeInfoHelper.get_symbol_info(info, "ETHBTC")
    ethbtc_lot = ExchangeInfoHelper.get_lot_size(symbol_info)
    assert ethbtc_lot.minQty == 0.00100000
    assert ethbtc_lot.maxQty == 100000.00000000
    assert ethbtc_lot.stepSize == 0.00100000
  end

  test "reduce exchange info to given symbols", %{exchange_info: info} do
    filtered = info
      |> ExchangeInfoHelper.reduce_to(["ETHBTC"])
    assert ExchangeInfoHelper.get_symbol_info(filtered, "ETHBTC")
    refute ExchangeInfoHelper.get_symbol_info(filtered, "LTCBTC")
  end
end
