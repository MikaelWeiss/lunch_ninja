defmodule LunchNinjaWeb.Hooks.Auth do
  @moduledoc """
  LiveView hooks for authentication.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  use LunchNinjaWeb, :verified_routes

  def on_mount(:ensure_authenticated, _params, session, socket) do
    access_token = session["access_token"]
    user_email = session["user_email"]

    if access_token && user_email do
      {:cont,
       socket
       |> assign(:access_token, access_token)
       |> assign(:user_email, user_email)}
    else
      {:halt, redirect(socket, to: ~p"/sign-in")}
    end
  end
end
