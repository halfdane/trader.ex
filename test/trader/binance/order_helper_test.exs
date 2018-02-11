defmodule Trader.Binance.OrderHelperTest do
  use ExUnit.Case

  test "calculate valid price" do
    tickSize = 0.00000100
    symbol_info = %{
      baseAssetPrecision: 8,
      filters: [
        %{
          filterType: "PRICE_FILTER",
          minPrice: 0.00000100,
          maxPrice: 100000.00000000,
          tickSize: tickSize
        }
      ]
    }

    c = Trader.Binance.OrderHelper.valid_price(String.to_float("0.10368701000000001"), symbol_info)
    assert Float.floor(c / tickSize) - (c / tickSize) == 0
  end

  test "calculate valid lot" do
    stepSize = 0.00100000
    symbol_info = %{
      baseAssetPrecision: 8,
      quotePrecision: 8,
      filters: [
        %{
          filterType: "LOT_SIZE",
          minQty: 0.00100000,
          maxQty: 100000.00000000,
          stepSize: stepSize
        }
      ]
    }

    c = Trader.Binance.OrderHelper.valid_lot(String.to_float("0.10368701000000001"), symbol_info)
    assert Float.floor(c / stepSize) - (c / stepSize) == 0

  end

end
