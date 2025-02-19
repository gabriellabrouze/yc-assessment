defmodule YC.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "")

    create table(:users) do
      add(:email, :citext, null: false)
      add(:family_name, :string, null: false)
      add(:given_name, :string, null: false)
      add(:picture, :string)
      add(:persona, :string)
      add(:hashed_password, :string, null: false)
      add(:confirmed_at, :utc_datetime)

      add(:persona_id, references(:personas), null: true)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:users, [:email]))

    create table(:users_tokens) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:token, :binary, null: false)
      add(:context, :string, null: false)
      add(:sent_to, :string)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create(index(:users_tokens, [:user_id]))
    create(unique_index(:users_tokens, [:context, :token]))
  end
end
