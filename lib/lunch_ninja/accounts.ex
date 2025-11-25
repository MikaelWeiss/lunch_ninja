defmodule LunchNinja.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias LunchNinja.Repo

  alias LunchNinja.Accounts.User
  alias LunchNinja.Accounts.MagicLinkToken

  # Users

  @doc """
  Returns the list of users for a school (excluding soft-deleted).
  """
  def list_users(school_id) do
    User
    |> where([u], u.school_id == ^school_id)
    |> where([u], is_nil(u.deleted_at))
    |> order_by([u], u.name)
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) when is_binary(email) do
    User
    |> where([u], u.email == ^email)
    |> where([u], is_nil(u.deleted_at))
    |> Repo.one()
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Soft deletes a user.
  """
  def delete_user(%User{} = user) do
    user
    |> Ecto.Changeset.change(deleted_at: DateTime.utc_now())
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # Magic Link Tokens

  @doc """
  Generates a magic link token for a user.

  Returns {:ok, token_string} where token_string is the unhashed token to send in the email.
  The hashed version is stored in the database.
  """
  def generate_magic_link(email) when is_binary(email) do
    user = get_user_by_email(email)

    if user do
      token_string = generate_token()
      hashed_token = hash_token(token_string)
      expires_at = DateTime.add(DateTime.utc_now(), 15, :minute)

      attrs = %{
        user_id: user.id,
        token: hashed_token,
        expires_at: expires_at
      }

      case create_magic_link_token(attrs) do
        {:ok, _token_record} -> {:ok, token_string, user}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, :user_not_found}
    end
  end

  @doc """
  Verifies a magic link token and marks it as used.

  Returns {:ok, user} if valid, {:error, reason} otherwise.
  """
  def verify_magic_link(token_string) when is_binary(token_string) do
    hashed_token = hash_token(token_string)
    now = DateTime.utc_now()

    query =
      from t in MagicLinkToken,
        where: t.token == ^hashed_token,
        where: t.expires_at > ^now,
        where: is_nil(t.used_at),
        preload: [:user]

    case Repo.one(query) do
      nil ->
        {:error, :invalid_or_expired}

      token_record ->
        token_record
        |> Ecto.Changeset.change(used_at: now)
        |> Repo.update()

        {:ok, token_record.user}
    end
  end

  @doc """
  Cleans up expired tokens (should be run periodically).
  """
  def clean_expired_tokens do
    cutoff = DateTime.add(DateTime.utc_now(), -1, :day)

    MagicLinkToken
    |> where([t], t.expires_at < ^cutoff)
    |> Repo.delete_all()
  end

  # Private functions

  defp create_magic_link_token(attrs) do
    %MagicLinkToken{}
    |> MagicLinkToken.changeset(attrs)
    |> Repo.insert()
  end

  defp generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end

  defp hash_token(token) do
    :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
  end
end
