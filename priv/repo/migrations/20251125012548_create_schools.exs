defmodule LunchNinja.Repo.Migrations.CreateSchools do
  use Ecto.Migration

  def change do
    create table(:schools, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :contact_email, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:schools, [:name])
    create unique_index(:schools, [:slug])
  end
end
