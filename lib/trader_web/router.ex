defmodule TraderWeb.Router do
  use TraderWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TraderWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/hello", HelloController, :index
    get "/hello/:messenger", HelloController, :show
    get "/coin/:symbol", CoinController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", TraderWeb do
  #   pipe_through :api
  # end
end