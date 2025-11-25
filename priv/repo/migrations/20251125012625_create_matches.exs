defmodule LunchNinja.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    execute "CREATE TYPE match_status AS ENUM ('scheduled', 'cancelled_by_user1', 'cancelled_by_user2', 'cancelled_by_both', 'completed')",
            "DROP TYPE match_status"

    execute "CREATE TYPE match_created_by AS ENUM ('system', 'admin')",
            "DROP TYPE match_created_by"

    create table(:matches, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :time_slot_id, references(:time_slots, type: :binary_id, on_delete: :delete_all),
        null: false

      add :date, :date, null: false
      add :user1_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :user2_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :status, :match_status, default: "scheduled", null: false
      add :created_by, :match_created_by, default: "system", null: false

      timestamps(type: :utc_datetime)
    end

    create index(:matches, [:user1_id, :date])
    create index(:matches, [:user2_id, :date])
    create index(:matches, [:time_slot_id, :date])
    create index(:matches, [:date])

    create constraint(:matches, :user1_less_than_user2, check: "user1_id < user2_id")
  end
end
