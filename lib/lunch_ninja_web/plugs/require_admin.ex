defmodule LunchNinjaWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller

  alias LunchNinja.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      user = Accounts.get_user!(user_id)

      if user.role == :admin do
        conn
      else
        conn
        |> put_flash(:error, "You must be an admin to access this page.")
        |> redirect(to: "/home")
        |> halt()
      end
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: "/auth/login")
      |> halt()
    end
  end
end
