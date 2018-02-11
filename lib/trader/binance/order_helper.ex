defmodule Trader.Binance.OrderHelper do
  alias Trader.Binance.ExchangeInfoHelper

  def valid_price(want_price, symbol_info) do
    price_filter = ExchangeInfoHelper.get_price_filter(symbol_info)
    want_price = Float.floor(want_price, symbol_info.baseAssetPrecision)
    Float.floor( want_price / price_filter.tickSize ) * price_filter.tickSize
  end

  def valid_lot(want_lot, symbol_info) do
    lot_size = ExchangeInfoHelper.get_lot_size(symbol_info)
    Float.floor( want_lot / lot_size.stepSize ) * lot_size.stepSize
  end

end
