defmodule Trader.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Trader.Repo, []),
      # Start the endpoint when the application starts
      supervisor(TraderWeb.Endpoint, []),
      {Trader.CoinTicker.Supervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Trader.Supervisor]
    Supervisor.start_link(children, opts)
    Trader.CoinTicker.Supervisor.start_ticker("ethbtc")
    Trader.CoinTicker.Supervisor.start_ticker("iostbtc")
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TraderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
