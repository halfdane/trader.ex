defmodule Trader.CoinTicker.Supervisor do
  use Supervisor
  def start_link(_whatever) do
    Supervisor.start_link(__MODULE__, [], name: :coin_ticker_supervisor)
  end
  def start_ticker(symbol) do
    Supervisor.start_child(:coin_ticker_supervisor, [symbol])
  end
  def init(_) do
    children = [
      worker(Trader.CoinTicker, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
