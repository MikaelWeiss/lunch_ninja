defmodule LunchNinjaWeb.UserAuth do
  use LunchNinjaWeb, :verified_routes

  import Phoenix.Component
  import Phoenix.LiveView

  alias LunchNinja.Accounts

  def on_mount(:require_authenticated_user, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> put_flash(:error, "You must be logged in to access this page.")
        |> redirect(to: ~p"/auth/login")

      {:halt, socket}
    end
  end

  def on_mount(:require_admin, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if socket.assigns[:current_user] && socket.assigns.current_user.role == :admin do
      {:cont, socket}
    else
      socket =
        socket
        |> put_flash(:error, "You must be an admin to access this page.")
        |> redirect(to: ~p"/home")

      {:halt, socket}
    end
  end

  def on_mount(:load_current_user, _params, session, socket) do
    {:cont, assign_current_user(socket, session)}
  end

  defp assign_current_user(socket, session) do
    case session do
      %{"user_id" => user_id, "school_id" => school_id} ->
        user = Accounts.get_user!(user_id)

        socket
        |> assign(:current_user, user)
        |> assign(:current_scope, user)
        |> assign(:school_id, school_id)

      _ ->
        assign(socket, :current_user, nil)
    end
  end
end
