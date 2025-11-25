defmodule LunchNinjaWeb.AuthController do
  use LunchNinjaWeb, :controller
  alias LunchNinja.Accounts
  alias LunchNinja.Emails

  def login_form(conn, _params) do
    render(conn, :login)
  end

  def send_magic_link(conn, %{"email" => email}) do
    case Accounts.generate_magic_link(email) do
      {:ok, token, user} ->
        email_struct = Emails.auth_magic_link(user, token)
        Emails.deliver(email_struct)

        conn
        |> put_flash(:info, "Check your email for a sign-in link!")
        |> redirect(to: ~p"/auth/login")

      {:error, :user_not_found} ->
        conn
        |> put_flash(:error, "No user found with that email address.")
        |> redirect(to: ~p"/auth/login")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong. Please try again.")
        |> redirect(to: ~p"/auth/login")
    end
  end

  def verify(conn, %{"token" => token}) do
    case Accounts.verify_magic_link(token) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_session(:school_id, user.school_id)
        |> put_flash(:info, "Welcome back, #{user.name}!")
        |> redirect(to: ~p"/home")

      {:error, :invalid_or_expired} ->
        conn
        |> put_flash(:error, "Invalid or expired link. Please request a new one.")
        |> redirect(to: ~p"/auth/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: ~p"/")
  end
end
