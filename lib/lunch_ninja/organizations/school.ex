defmodule LunchNinja.Organizations.School do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "schools" do
    field :name, :string
    field :slug, :string
    field :contact_email, :string

    has_many :users, LunchNinja.Accounts.User
    has_many :time_slots, LunchNinja.Organizations.TimeSlot

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(school, attrs) do
    school
    |> cast(attrs, [:name, :slug, :contact_email])
    |> validate_required([:name, :slug])
    |> validate_format(:contact_email, ~r/@/, message: "must be a valid email")
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric and dashes only"
    )
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
