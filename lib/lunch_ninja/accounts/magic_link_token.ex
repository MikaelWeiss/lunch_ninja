defmodule LunchNinja.Accounts.MagicLinkToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "magic_link_tokens" do
    field :token, :string
    field :expires_at, :utc_datetime
    field :used_at, :utc_datetime

    belongs_to :user, LunchNinja.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(magic_link_token, attrs) do
    magic_link_token
    |> cast(attrs, [:token, :expires_at, :used_at, :user_id])
    |> validate_required([:token, :expires_at, :user_id])
    |> unique_constraint(:token)
    |> foreign_key_constraint(:user_id)
  end
end
