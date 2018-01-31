defmodule Trader.Worker do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
      uri(:time)
        |> binance
        |> log
      schedule_work()
      {:ok, state}
  end

  def handle_info(:work, state) do
      uri(:trades, %{symbol: :ETHBTC, limit: 1})
        |> binance
        |> Enum.at(-1)
        |> addPercentages
        |> log

      schedule_work() # Reschedule once more
      {:noreply, state}
  end

  defp addPercentages(order) do
    %{"id" => _id,
      "isBestMatch" => _bestMatch,
      "isBuyerMaker" => _buyerMaker,
      "price" => price_str,
      "qty" => _quantity,
      "time" => _time} = order

    price = String.to_float(price_str)
    max = price + (price * 0.03)
    min = price - (price * 0.01)

    order
      |> Map.merge(%{"maxPrice" => max, "minPrice" => min})
  end

  defp schedule_work() do
      Process.send_after(self(), :work, 1000) # In 1 sec
  end

  defp uri(endpoint) do
    "https://api.binance.com/api/v1/#{endpoint}"
  end

  defp uri(endpoint, parameters) do
    "#{uri(endpoint)}?#{URI.encode_query(parameters)}"
  end

  defp binance(url) do
    response = HTTPoison.get!(url)
    req = Poison.decode!(response.body)
  end

  defp log(object) do
    Logger.info "#{inspect(object)}"
  end

end
