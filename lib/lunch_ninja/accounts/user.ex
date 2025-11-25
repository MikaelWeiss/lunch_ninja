defmodule LunchNinja.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :name, :string
    field :role, Ecto.Enum, values: [:admin, :teacher, :student]
    field :deleted_at, :utc_datetime

    belongs_to :school, LunchNinja.Organizations.School
    has_many :magic_link_tokens, LunchNinja.Accounts.MagicLinkToken
    has_many :availability, LunchNinja.Scheduling.Availability

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :role, :school_id])
    |> validate_required([:email, :name, :role, :school_id])
    |> validate_format(:email, ~r/@/, message: "must be a valid email")
    |> validate_inclusion(:role, [:admin, :teacher, :student])
    |> unique_constraint(:email)
    |> foreign_key_constraint(:school_id)
  end
end
