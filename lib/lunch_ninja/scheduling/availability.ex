defmodule LunchNinja.Scheduling.Availability do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "availability" do
    field :date, :date

    belongs_to :user, LunchNinja.Accounts.User
    belongs_to :time_slot, LunchNinja.Organizations.TimeSlot

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(availability, attrs) do
    availability
    |> cast(attrs, [:date, :user_id, :time_slot_id])
    |> validate_required([:date, :user_id, :time_slot_id])
    |> validate_future_date()
    |> unique_constraint([:user_id, :time_slot_id, :date],
      name: :availability_user_id_time_slot_id_date_index
    )
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:time_slot_id)
  end

  defp validate_future_date(changeset) do
    date = get_field(changeset, :date)
    today = Date.utc_today()

    if date && Date.compare(date, today) == :lt do
      add_error(changeset, :date, "cannot be in the past")
    else
      changeset
    end
  end
end
