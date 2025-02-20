# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     YC.Repo.insert!(%YC.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias YC.Repo
alias YC.Personas.Persona

personas = [
  %{
    name: "Gourmet Chef",
    description: "A master of fine dining and intricate recipes.",
    # Coral
    colour: "FF6F61",
    badge: "chef"
  },
  %{
    name: "Health Nut",
    description: "Focused on clean eating, superfoods, and plant-based recipes.",
    # Green
    colour: "88B04B",
    badge: "apple"
  },
  %{
    name: "Weekend Baker",
    description: "A baking enthusiast who loves indulgent sweet treats.",
    # Blush
    colour: "F7CAC9",
    badge: "cake"
  },
  %{
    name: "Grill Master",
    description: "The king or queen of the barbecue and outdoor cooking.",
    # Red
    colour: "DD4124",
    badge: "grill"
  }
]

Enum.each(personas, fn persona ->
  %Persona{}
  |> Persona.changeset(persona)
  |> Repo.insert!()
end)
