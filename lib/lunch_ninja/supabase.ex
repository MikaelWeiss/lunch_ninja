defmodule LunchNinja.Supabase do
  @moduledoc """
  Supabase client for authentication and database operations.
  Uses HTTP REST API with Req.
  """

  @doc """
  Returns the Supabase configuration.
  """
  def config do
    Application.get_env(:lunch_ninja, :supabase)
  end

  @doc """
  Returns the Supabase project URL.
  """
  def url, do: config()[:url]

  @doc """
  Returns the Supabase anon key.
  """
  def anon_key, do: config()[:anon_key]

  @doc """
  Check if an email exists in the users table.
  Calls the Supabase RPC function `check_email_exists`.
  """
  def email_exists?(email) when is_binary(email) do
    case Req.post(
           "#{url()}/rest/v1/rpc/check_email_exists",
           json: %{user_email: email},
           headers: [
             {"apikey", anon_key()},
             {"Authorization", "Bearer #{anon_key()}"},
             {"Content-Type", "application/json"}
           ]
         ) do
      {:ok, %Req.Response{status: 200, body: result}} ->
        {:ok, result}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Supabase error: #{status} - #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Send a magic link to the user's email for passwordless authentication.
  Only sends if the email exists in our users table.
  """
  def send_magic_link(email, redirect_to \\ nil) when is_binary(email) do
    body =
      %{
        email: email,
        options: %{
          should_create_user: false
        }
      }
      |> maybe_add_redirect(redirect_to)

    case Req.post(
           "#{url()}/auth/v1/otp",
           json: body,
           headers: [
             {"apikey", anon_key()},
             {"Content-Type", "application/json"}
           ]
         ) do
      {:ok, %Req.Response{status: 200}} ->
        :ok

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Auth error: #{status} - #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Verify an OTP token from a magic link callback.
  """
  def verify_otp(token_hash, type \\ "email") do
    case Req.post(
           "#{url()}/auth/v1/verify",
           json: %{
             token_hash: token_hash,
             type: type
           },
           headers: [
             {"apikey", anon_key()},
             {"Content-Type", "application/json"}
           ]
         ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Verification error: #{status} - #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Get the current user from an access token.
  """
  def get_user(access_token) when is_binary(access_token) do
    case Req.get(
           "#{url()}/auth/v1/user",
           headers: [
             {"apikey", anon_key()},
             {"Authorization", "Bearer #{access_token}"}
           ]
         ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "User error: #{status} - #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Get the user profile from our users table by email.
  """
  def get_user_profile(email, access_token) when is_binary(email) do
    case Req.get(
           "#{url()}/rest/v1/users?email=eq.#{URI.encode(email)}&select=*,schools(name)",
           headers: [
             {"apikey", anon_key()},
             {"Authorization", "Bearer #{access_token}"},
             {"Accept", "application/json"}
           ]
         ) do
      {:ok, %Req.Response{status: 200, body: [user | _]}} ->
        {:ok, user}

      {:ok, %Req.Response{status: 200, body: []}} ->
        {:error, :not_found}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Profile error: #{status} - #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp maybe_add_redirect(body, nil), do: body

  defp maybe_add_redirect(body, redirect_to) do
    put_in(body, [:options, :email_redirect_to], redirect_to)
  end
end
