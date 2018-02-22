defmodule Trader.Order.BinanceTest do
  # Use the module
  use ExUnit.Case, async: true
  alias Trader.Order.Binance

  # example taken from
  # https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#signed-endpoint-examples-for-post-apiv1order
  @params [
    symbol: "LTCBTC",
    side: "BUY",
    type: "LIMIT",
    timeInForce: "GTC",
    quantity: "1",
    price: 0.1,
    recvWindow: 5000,
    timestamp: 1_499_827_319_559
  ]

  @binance_access %{
    key: "vmPUZE6mv9SD5VNHk4HlWFsOr6aKE2zvsw0MuIgwCIPy6utIco14y7Ju91duEh8A",
    secret: "NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j"
  }

  test "create query string" do
    assert Binance.create_query_string(@params) ==
             "symbol=LTCBTC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=1&price=0.1&recvWindow=5000&timestamp=1499827319559"
  end

  test "calculate signature" do
    query = Binance.create_query_string(@params)

    assert Binance.calculate_signature(query, @binance_access) ==
             "c8db56825ae71d6d79447849e617115f4a920fa2acdcab2b053c4b2838bd6b71"
  end

  test "complete query" do
    signed = Binance.sign(@params, @binance_access)

    assert signed.query ==
             "symbol=LTCBTC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=1&price=0.1&recvWindow=5000&timestamp=1499827319559&signature=c8db56825ae71d6d79447849e617115f4a920fa2acdcab2b053c4b2838bd6b71"

    assert signed.headers == [{"X-MBX-APIKEY", "#{@binance_access.key}"}]
  end

  test "sign only if access info given" do
    signed = Binance.sign(@params, %{})

    assert signed.query ==
             "symbol=LTCBTC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=1&price=0.1&recvWindow=5000&timestamp=1499827319559"

    assert signed.headers == []
  end

  test "get given asset's balance" do
    account_info = %{
      "balances" => [
        %{"asset" => "BTC", "free" => "0.00003491", "locked" => "0.00000000"},
        %{"asset" => "LTC", "free" => "0.00000000", "locked" => "0.00000000"},
        %{"asset" => "ETH", "free" => "0.03500333", "locked" => "0.00000000"},
        %{"asset" => "BNC", "free" => "0.00000000", "locked" => "0.00000000"}
      ]
    }

    assert Binance.get_balance_from_account_info(account_info, "ETH") == "0.03500333"
  end

  test "add parameters" do
    args =
      []
      |> Binance.add(one: :value)
      |> Binance.add(two: nil)
      |> Binance.add(three: :another_value)

    assert args == [one: :value, three: :another_value]
  end
end
