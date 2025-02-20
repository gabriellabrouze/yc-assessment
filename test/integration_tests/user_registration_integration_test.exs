defmodule YCWeb.UserRegistrationIntegrationTest do
  use YCWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias YC.Accounts.User
  alias YC.Personas
  alias YC.Repo

  test "successful user registration with profile picture and persona", %{conn: conn} do
    persona = insert(:persona)
    {:ok, view, _html} = live(conn, ~p"/users/register")

    # Fill out the form
    view
    |> form("#registration_form", %{
      user: %{
        given_name: "John",
        family_name: "Doe",
        email: "john.doe@example.com",
        password: "password123!!!",
        persona_id: persona.id
      }
    })
    |> render_submit()

    # Verify the user was created
    assert Repo.get_by(User, email: "john.doe@example.com")
  end

  defp insert(:persona) do
    {:ok, persona} =
      Personas.create_persona(%{
        name: "Health Nut",
        description: "healthy person",
        badge: "apple",
        colour: "FFF000"
      })

    persona
  end
end
