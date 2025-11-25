defmodule LunchNinja.Repo.Migrations.CreateTimeSlots do
  use Ecto.Migration

  def change do
    create table(:time_slots, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :school_id, references(:schools, type: :binary_id, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :start_time, :time, null: false
      add :end_time, :time, null: false
      add :active, :boolean, default: true, null: false
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:time_slots, [:school_id])
    create index(:time_slots, [:school_id, :active])
  end
end
