defmodule YC.Personas.Persona do
  use Ecto.Schema
  import Ecto.Changeset

  schema "personas" do
    field(:name, :string)
    field(:description, :string)
    field(:colour, :string)
    field(:badge, :string)

    timestamps(type: :utc_datetime)
  end

  def changeset(persona, attrs) do
    persona
    |> cast(attrs, [:name, :description, :colour, :badge])
    |> validate_required([:name, :colour])
    |> validate_length(:colour, is: 6)
  end
end
