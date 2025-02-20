defmodule YC.PersonasTest do
  alias YC.Personas.Persona
  use YC.DataCase, async: true

  alias YC.Personas

  describe "fetch_options/0" do
    test "returns a list of personas as {name, id} tuples" do
      persona = insert(:persona, valid_attrs())
      assert Personas.fetch_options() == [{persona.name, persona.id}]
    end
  end

  describe "fetch_personas/0" do
    test "returns a list of personas" do
      insert(:persona, valid_attrs())
      assert Personas.fetch_personas() |> length() == 1
    end
  end

  describe "create_persona/1" do
    test "returns a list of personas" do
      assert {:ok, %Persona{}} =
               Personas.create_persona(valid_attrs())
    end
  end

  defp valid_attrs do
    %{
      name: "Health Nut",
      description: "healthy person",
      badge: "apple",
      colour: "FFF000"
    }
  end

  def insert(:persona, attrs) do
    {:ok, persona} = Personas.create_persona(attrs)
    persona
  end
end
