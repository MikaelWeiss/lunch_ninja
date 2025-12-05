defmodule LunchNinjaWeb.Plugs.RequireAuth do
  @moduledoc """
  Plug to require authentication for protected routes.
  """
  import Plug.Conn
  import Phoenix.Controller

  use LunchNinjaWeb, :verified_routes

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, :access_token) do
      conn
      |> assign(:current_user_email, get_session(conn, :user_email))
    else
      conn
      |> put_flash(:error, "You must sign in to access this page.")
      |> redirect(to: ~p"/sign-in")
      |> halt()
    end
  end
end
