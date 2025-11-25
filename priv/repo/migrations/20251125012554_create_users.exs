defmodule LunchNinja.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE TYPE user_role AS ENUM ('admin', 'teacher', 'student')", "DROP TYPE user_role"

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :name, :string, null: false
      add :role, :user_role, null: false
      add :school_id, references(:schools, type: :binary_id, on_delete: :delete_all), null: false
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create index(:users, [:school_id])
    create index(:users, [:school_id, :role])
  end
end
