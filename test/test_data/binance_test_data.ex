defmodule Trader.Testdata do
  def binance_exchange_info, do: "{
    \"timezone\": \"UTC\",
    \"serverTime\": 1518346065499,
    \"rateLimits\": [
      {
        \"rateLimitType\": \"REQUESTS\",
        \"interval\": \"MINUTE\",
        \"limit\": 1200
      },
      {
        \"rateLimitType\": \"ORDERS\",
        \"interval\": \"SECOND\",
        \"limit\": 10
      },
      {
        \"rateLimitType\": \"ORDERS\",
        \"interval\": \"DAY\",
        \"limit\": 100000
      }
    ],
    \"exchangeFilters\": [

    ],
    \"symbols\": [
      {
        \"symbol\": \"ETHBTC\",
        \"status\": \"TRADING\",
        \"baseAsset\": \"ETH\",
        \"baseAssetPrecision\": 8,
        \"quoteAsset\": \"BTC\",
        \"quotePrecision\": 8,
        \"orderTypes\": [
          \"LIMIT\",
          \"LIMIT_MAKER\",
          \"MARKET\",
          \"STOP_LOSS_LIMIT\",
          \"TAKE_PROFIT_LIMIT\"
        ],
        \"icebergAllowed\": true,
        \"filters\": [
          {
            \"filterType\": \"PRICE_FILTER\",
            \"minPrice\": \"0.00000100\",
            \"maxPrice\": \"100000.00000000\",
            \"tickSize\": \"0.00000100\"
          },
          {
            \"filterType\": \"LOT_SIZE\",
            \"minQty\": \"0.00100000\",
            \"maxQty\": \"100000.00000000\",
            \"stepSize\": \"0.00100000\"
          },
          {
            \"filterType\": \"MIN_NOTIONAL\",
            \"minNotional\": \"0.00100000\"
          }
        ]
      },
      {
        \"symbol\": \"LTCBTC\",
        \"status\": \"TRADING\",
        \"baseAsset\": \"LTC\",
        \"baseAssetPrecision\": 8,
        \"quoteAsset\": \"BTC\",
        \"quotePrecision\": 8,
        \"orderTypes\": [
          \"LIMIT\",
          \"LIMIT_MAKER\",
          \"MARKET\",
          \"STOP_LOSS_LIMIT\",
          \"TAKE_PROFIT_LIMIT\"
        ],
        \"icebergAllowed\": true,
        \"filters\": [
          {
            \"filterType\": \"PRICE_FILTER\",
            \"minPrice\": \"0.00000100\",
            \"maxPrice\": \"100000.00000000\",
            \"tickSize\": \"0.00000100\"
          },
          {
            \"filterType\": \"LOT_SIZE\",
            \"minQty\": \"0.01000000\",
            \"maxQty\": \"100000.00000000\",
            \"stepSize\": \"0.01000000\"
          },
          {
            \"filterType\": \"MIN_NOTIONAL\",
            \"minNotional\": \"0.00100000\"
          }
        ]
      }]
    }"
end
