defmodule Trader.CoinTicker.Supervisor do
  use Supervisor
  require Logger
  def start_link(_whatever) do
    Supervisor.start_link(__MODULE__, [], name: :coin_ticker_supervisor)
  end
  def init(_) do
    children = [
      worker(Trader.CoinTicker, [])
    ]
    Task.start_link(&start_tickers_of_binance/0)

    supervise(children, strategy: :simple_one_for_one)
  end

  def handle_info(:start_tickers, config) do
    Logger.info "info"
     start_tickers_of_binance()
     {:noreply, config}
   end

  def start_ticker(symbol) do
    Supervisor.start_child(:coin_ticker_supervisor, [symbol])
  end

  def start_tickers_of_binance do
    case HTTPoison.get "https://api.binance.com/api/v1/exchangeInfo" do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> start_children(body)
      {_, poison_info} -> Logger.info "Something went wrong: #{inspect poison_info}"
    end
  end
  defp start_children(body) do
    body
      |> Poison.decode!
      |> extract_symbols
      |> Enum.map(&start_ticker/1)
  end

  defp extract_symbols(exchange_info) do
    exchange_info["symbols"]
      |> Enum.map(&(%{symbol: &1["symbol"], base: &1["baseAsset"], quote: &1["quoteAsset"]}))
  end
end
