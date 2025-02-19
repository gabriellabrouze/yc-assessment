defmodule YC.Repo.Migrations.CreatePersonas do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "")

    create table(:personas) do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:colour, :string, null: false)
      add(:badge, :string)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:personas, [:name]))
  end
end
