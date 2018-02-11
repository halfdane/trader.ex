defmodule Trader.Binance.ExchangeInfoTest do
  use ExUnit.Case

  alias Trader.Binance.ExchangeInfo
  alias Trader.Testdata

  setup do
    {:ok,server_pid} = ExchangeInfo.start_link(Testdata.binance_exchange_info)
    {:ok,server: server_pid}
  end

  test "get symbol info", %{server: pid} do
    assert :ok == ExchangeInfo.get_symbol("ETHBTC")
  end

end
