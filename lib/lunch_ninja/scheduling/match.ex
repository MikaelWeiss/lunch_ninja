defmodule LunchNinja.Scheduling.Match do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "matches" do
    field :date, :date

    field :status, Ecto.Enum,
      values: [
        :scheduled,
        :cancelled_by_user1,
        :cancelled_by_user2,
        :cancelled_by_both,
        :completed
      ],
      default: :scheduled

    field :created_by, Ecto.Enum, values: [:system, :admin], default: :system

    belongs_to :time_slot, LunchNinja.Organizations.TimeSlot
    belongs_to :user1, LunchNinja.Accounts.User
    belongs_to :user2, LunchNinja.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:date, :status, :created_by, :time_slot_id, :user1_id, :user2_id])
    |> validate_required([:date, :time_slot_id, :user1_id, :user2_id])
    |> validate_different_users()
    |> foreign_key_constraint(:time_slot_id)
    |> foreign_key_constraint(:user1_id)
    |> foreign_key_constraint(:user2_id)
  end

  defp validate_different_users(changeset) do
    user1_id = get_field(changeset, :user1_id)
    user2_id = get_field(changeset, :user2_id)

    if user1_id && user2_id && user1_id == user2_id do
      add_error(changeset, :user2_id, "must be different from user1")
    else
      changeset
    end
  end
end
