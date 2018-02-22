defmodule TraderWeb.UserController do
  use TraderWeb, :controller

  alias Trader.Repo
  alias Trader.Auth
  alias Trader.Auth.User
  alias Trader.Auth.Role

  plug(:scrub_params, "user" when action in [:create])

  def new(conn, _params) do
    changeset = Auth.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    role =
      Repo.all(Role)
      |> Enum.filter(&(!&1.admin))
      |> List.first()

    user_params = Map.put(user_params, "role_id", role.id)

    case Auth.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> Trader.Auth.Guardian.Plug.sign_in(user)
        |> redirect(to: user_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    user = conn.assigns.current_user
    render(conn, "show.html", user: user)
  end

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = Auth.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Auth.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    user = conn.assigns.current_user
    {:ok, _user} = Auth.delete_user(user)

    conn
    |> Trader.Auth.Guardian.Plug.sign_out()
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: page_path(conn, :index))
  end
end
