defmodule YC.Personas do
  @moduledoc """
  The Personas context.
  """
  import Ecto.Query, warn: false
  alias YC.Repo

  alias YC.Personas.Persona

  ## Database getters

  @doc """
  Fetch all personas from the DB"
  """
  def fetch_personas do
    Repo.all(Persona)
  end

  @doc """
  Fetch all personas from the DB and format as selectable options for select input.
  """
  def fetch_options do
    fetch_personas()
    |> Enum.map(&{&1.name, &1.id})
  end

  ## Create Personas

  @doc """
  Create and Add Kitchen Persona to DB
  """
  def create_persona(attrs) do
    %Persona{}
    |> Persona.changeset(attrs)
    |> Repo.insert()
  end
end
