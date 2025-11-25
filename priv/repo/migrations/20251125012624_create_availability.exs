defmodule LunchNinja.Repo.Migrations.CreateAvailability do
  use Ecto.Migration

  def change do
    create table(:availability, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :time_slot_id, references(:time_slots, type: :binary_id, on_delete: :delete_all),
        null: false

      add :date, :date, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:availability, [:user_id, :date])
    create index(:availability, [:time_slot_id, :date])
    create index(:availability, [:date])
    create unique_index(:availability, [:user_id, :time_slot_id, :date])
  end
end
