defmodule LunchNinja.Organizations.TimeSlot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "time_slots" do
    field :name, :string
    field :start_time, :time
    field :end_time, :time
    field :active, :boolean, default: true
    field :deleted_at, :utc_datetime

    belongs_to :school, LunchNinja.Organizations.School
    has_many :availability, LunchNinja.Scheduling.Availability
    has_many :matches, LunchNinja.Scheduling.Match

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(time_slot, attrs) do
    time_slot
    |> cast(attrs, [:name, :start_time, :end_time, :active, :school_id])
    |> validate_required([:name, :start_time, :end_time, :school_id])
    |> validate_time_order()
    |> foreign_key_constraint(:school_id)
  end

  defp validate_time_order(changeset) do
    start_time = get_field(changeset, :start_time)
    end_time = get_field(changeset, :end_time)

    if start_time && end_time && Time.compare(start_time, end_time) != :lt do
      add_error(changeset, :end_time, "must be after start time")
    else
      changeset
    end
  end
end
