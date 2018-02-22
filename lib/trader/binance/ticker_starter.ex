defmodule Trader.Binance.TickerStarter do
  require Logger
  alias Trader.Binance.ExchangeInfo

  def start_tickers_of_binance do
    Logger.info("Getting exchange information from binance")

    case HTTPoison.get("https://api.binance.com/api/v1/exchangeInfo") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> start_children(body)
      {_, poison_info} -> Logger.info("Something went wrong: #{inspect(poison_info)}")
    end
  end

  defp start_children(body) do
    body
    |> ExchangeInfo.start_link()

    {:ok, symbols} = ExchangeInfo.get_symbols()

    symbols
    |> Enum.map(& &1.symbol)
    |> Enum.map(&start_ticker/1)
  end

  def start_ticker(symbol) do
    Task.start_link(fn ->
      DynamicSupervisor.start_child(Trader.Binance.TickerSupervisor, {Trader.Binance.CandleTicker, symbol})
    end)
    Task.start_link(fn ->
      DynamicSupervisor.start_child(Trader.Binance.TickerSupervisor, {Trader.Binance.AggTradeTicker, symbol})
    end)
  end
end
