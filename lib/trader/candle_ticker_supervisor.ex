defmodule Trader.CandleTicker.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :coin_ticker_supervisor)
  end

  def init(_) do
    children = [worker(Trader.CandleTicker, [])]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_ticker(symbol) do
    Supervisor.start_child(:coin_ticker_supervisor, [symbol])
  end
end

defmodule Trader.CandleTicker.Supervisor.Starter do
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
    |> Enum.map(&Trader.CandleTicker.Supervisor.start_ticker/1)
  end

  def start_ticker(symbol) do
    Task.start_link(fn ->
      Trader.CandleTicker.Supervisor.start_ticker(symbol)
    end)
  end
end
