defmodule Trader.Order.Binance do
  @endpoint "https://api.binance.com"
  require Logger

  defp get_binance(url, params \\ [], binance_auth \\ %{}) do
    signed = sign(params, binance_auth)
    case HTTPoison.get("#{@endpoint}#{url}?#{signed.query}", signed.headers) do
      {:error, err} ->
        {:error, {:http_error, err}}
      {:ok, response} ->
        case Poison.decode(response.body) do
          {:ok, data} -> {:ok, data}
          {:error, err} -> {:error, {:poison_decode_error, err}}
        end
    end
  end

  defp post_binance(url, params, binance_auth) do
    signed = sign(params, binance_auth)
    Logger.info inspect signed
    case HTTPoison.post("#{@endpoint}#{url}", signed.query, signed.headers) do
      {:error, err} ->
        {:error, {:http_error, err}}
      {:ok, response} ->
        case Poison.decode(response.body) do
          {:ok, data} -> {:ok, data}
          {:error, err} -> {:error, {:poison_decode_error, err}}
        end
    end
  end

  def sign(params, binance_access) when binance_access == %{} do
    %{query: "#{create_query_string(params)}", headers:  [] }
  end

  def sign(params, binance_access) do
    signature = params
      |> create_query_string
      |> calculate_signature(binance_access)

    query = params ++ [signature: signature]
      |> create_query_string

    %{query: "#{query}", headers:  [{"X-MBX-APIKEY", binance_access.key}] }
  end

  def create_query_string(params) do
    params
      |> Enum.map(fn x -> Tuple.to_list(x) |> Enum.join("=") end)
      |> Enum.join("&")
  end

  def calculate_signature(aString, binance_access) do
      :crypto.hmac(:sha256, binance_access.secret, aString)
        |> Base.encode16()
        |> String.downcase
  end

  # Server

  @doc """
  Pings binance API. Returns `{:ok, %{}}` if successful, `{:error, reason}` otherwise
  """
  def ping() do
    get_binance("/api/v1/ping")
  end

  @doc """
  Get binance server time in unix epoch.

  Returns `{:ok, time}` if successful, `{:error, reason}` otherwise

  ## Example
  ```
  {:ok, 1515390701097}
  ```

  """
  def get_server_time() do
    case get_binance("/api/v1/time") do
      {:ok, %{"serverTime" => time}} -> {:ok, time}
      err -> err
    end
  end

  # Ticker

  @doc """
  Get all symbols and current prices listed in binance

  Returns `{:ok, [%Binance.SymbolPrice{}]}` or `{:error, reason}`.

  ## Example
  ```
  {:ok,
    [%Binance.SymbolPrice{price: "0.07579300", symbol: "ETHBTC"},
     %Binance.SymbolPrice{price: "0.01670200", symbol: "LTCBTC"},
     %Binance.SymbolPrice{price: "0.00114550", symbol: "BNBBTC"},
     %Binance.SymbolPrice{price: "0.00640000", symbol: "NEOBTC"},
     %Binance.SymbolPrice{price: "0.00030000", symbol: "123456"},
     %Binance.SymbolPrice{price: "0.04895000", symbol: "QTUMETH"},
     ...]}
  ```
  """
  def get_all_prices() do
    get_binance("/api/v1/ticker/allPrices")
  end

  @doc """
  Retrieves the current ticker information for the given trade pair.

  Symbol can be a binance symbol in the form of `"ETHBTC"` or `%Binance.TradePair{}`.

  Returns `{:ok, %Binance.Ticker{}}` or `{:error, reason}`

  ## Example
  ```
  {:ok,
    %Binance.Ticker{ask_price: "0.07548800", bid_price: "0.07542100",
      close_time: 1515391124878, count: 661676, first_id: 16797673,
      high_price: "0.07948000", last_id: 17459348, last_price: "0.07542000",
      low_price: "0.06330000", open_price: "0.06593800", open_time: 1515304724878,
      prev_close_price: "0.06593800", price_change: "0.00948200",
      price_change_percent: "14.380", volume: "507770.18500000",
      weighted_avg_price: "0.06946930"}}
  ```
  """
  def get_ticker(symbol) when is_binary(symbol) do
    get_binance("/api/v1/ticker/24hr", [symbol: symbol])
  end

  def user_info(binance_access) do
    case get_binance("/api/v3/account", [timestamp: :os.system_time(:millisecond)], binance_access) do
      {:ok, info} -> info
      all -> all
    end
  end

  def get_balance(binance_access, symbol) do
    user_info(binance_access)
      |> get_balance_from_account_info(symbol)
  end

  def get_balance_from_account_info(user_info, symbol) do
    user_info["balances"]
      |> Enum.filter(&(&1["asset"] == symbol))
      |> List.first
      |> Map.get("free")
  end

  # Order

  @doc """
  Creates a new order on binance

  Returns `{:ok, %{}}` or `{:error, reason}`.

  In the case of a error on binance, for example with invalid parameters, `{:error, {:binance_error, %{code: code, msg: msg}}}` will be returned.

  Please read https://www.binance.com/restapipub.html#user-content-account-endpoints to understand all the parameters
  """
  def create_order(
        binance_auth,
        symbol,
        side,
        type,
        quantity,
        price \\ nil,
        time_in_force \\ nil,
        new_client_order_id \\ nil,
        stop_price \\ nil,
        iceberg_quantity \\ nil,
        receiving_window \\ 5000,
        timestamp \\ nil
      ) do
    timestamp =
      case timestamp do
        # timestamp needs to be in milliseconds
        nil ->
          :os.system_time(:millisecond)

        t ->
          t
      end

    arguments =
      [
        symbol: symbol,
        side: side,
        type: type,
        quantity: quantity,
        timestamp: timestamp,
        recvWindow: receiving_window
      ]
      |> add(newClientOrderId: new_client_order_id)
      |> add(stopPrice: stop_price)
      |> add(icebergQty: iceberg_quantity)
      |> add(timeInForce: time_in_force)
      |> add(price: price)

    case post_binance("/api/v3/order/test", arguments, binance_auth) do
      {:ok, %{"code" => code, "msg" => msg}} ->
        {:error, {:binance_error, %{code: code, msg: msg}}}
      data -> data
    end
  end

  def add(args, [{_, nil}]), do: args
  def add(args, pair), do: args ++ pair

  @doc """
  Creates a new **limit** **buy** order

  Symbol can be a binance symbol in the form of `"ETHBTC"` or `%Binance.TradePair{}`.

  Returns `{:ok, %{}}` or `{:error, reason}`
  """
  def order_limit_buy(binance_auth, symbol, quantity, price)
      when is_binary(symbol)
      when is_number(quantity)
      when is_number(price) do
    create_order(binance_auth, symbol, "BUY", "LIMIT", quantity, price, "GTC")
  end

  @doc """
  Creates a new **limit** **sell** order

  Symbol can be a binance symbol in the form of `"ETHBTC"` or `%Binance.TradePair{}`.

  Returns `{:ok, %{}}` or `{:error, reason}`
  """
  def order_limit_sell(binance_auth, symbol, quantity, price)
      when is_binary(symbol)
      when is_number(quantity)
      when is_number(price) do
    create_order(binance_auth, symbol, "SELL", "LIMIT", quantity, price, "GTC")
  end

  @doc """
  Creates a new **market** **buy** order

  Symbol can be a binance symbol in the form of `"ETHBTC"` or `%Binance.TradePair{}`.

  Returns `{:ok, %{}}` or `{:error, reason}`
  """
  def order_market_buy(binance_auth, symbol, quantity)
      when is_binary(symbol)
      when is_number(quantity) do
    create_order(binance_auth, symbol, "BUY", "MARKET", quantity)
  end

  @doc """
  Creates a new **market** **sell** order

  Symbol can be a binance symbol in the form of `"ETHBTC"` or `%Binance.TradePair{}`.

  Returns `{:ok, %{}}` or `{:error, reason}`
  """
  def order_market_sell(binance_auth, symbol, quantity)
      when is_binary(symbol)
      when is_number(quantity) do
    create_order(binance_auth, symbol, "SELL", "MARKET", quantity)
  end

end
