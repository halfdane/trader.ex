defmodule TraderWeb.Router do
  use TraderWeb, :router
  require Logger

  pipeline :auth do
    plug Trader.Auth.Pipeline
    plug Trader.Auth.CurrentUser
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

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

  # Maybe logged in scope
  scope "/", TraderWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index

    get "/coin/:symbol", CoinController, :index


    get "/users/new", UserController, :new
    post "/users", UserController, :create

    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  # Definitely logged in scope
  scope "/", TraderWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/user/edit", UserController, :edit
    get "/user/", UserController, :show
    patch "/user/", UserController, :update
    put "/user/", UserController, :update
    delete "/user/", UserController, :delete

    post "/orders/", OrdersController, :create
  end
end
