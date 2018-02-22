defmodule Trader.Notify do
  alias Phoenix.PubSub

  def sub_candles(symbol) do
    PubSub.subscribe(:notifications, "#{symbol}:candles")
  end

  def sub_agg_trades(symbol) do
    PubSub.subscribe(:notifications, "#{symbol}:agg_trades")
  end

  def sub_signals(symbol) do
    PubSub.subscribe(:notifications, "#{symbol}:signals")
  end

  def candle(candle) do
    PubSub.broadcast(:notifications, "#{candle.symbol}:candles", {:candle, candle})
  end

  def agg_trade(agg_trade) do
    PubSub.broadcast(:notifications, "#{agg_trade.symbol}:agg_trades", {:agg_trade, agg_trade})
  end

  def signal(signal) do
    PubSub.broadcast(:notifications, "#{signal.symbol}:signals", {:signal, signal})
  end
end
