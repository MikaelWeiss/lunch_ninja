defmodule LunchNinjaWeb.AuthController do
  use LunchNinjaWeb, :controller

  alias LunchNinja.Supabase

  @doc """
  Handle the magic link callback from Supabase.
  The URL will contain token_hash and type parameters.
  """
  def callback(conn, %{"token_hash" => token_hash, "type" => type}) do
    case Supabase.verify_otp(token_hash, type) do
      {:ok, %{"access_token" => access_token, "user" => user}} ->
        conn
        |> put_session(:access_token, access_token)
        |> put_session(:user_email, user["email"])
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: ~p"/dashboard")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Sign in failed: #{inspect(reason)}")
        |> redirect(to: ~p"/sign-in")
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Invalid sign in link. Please try again.")
    |> redirect(to: ~p"/sign-in")
  end

  @doc """
  Sign out the current user.
  """
  def sign_out(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You've been signed out.")
    |> redirect(to: ~p"/")
  end
end
