defmodule YCWeb.UserRegistrationLive do
  use YCWeb, :live_view

  alias YC.Accounts
  alias YC.Accounts.User
  alias YC.Personas
  alias YCWeb.UploadWidgetComponent

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>
        <.live_component
          module={UploadWidgetComponent}
          id="upload-widget"
          image_url={@image_url}
          persona={@current_persona}
        />
        <.input field={@form[:given_name]} type="text" label="First Name" required />
        <.input field={@form[:family_name]} type="text" label="Last Name" required />
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input field={@form[:picture]} type="hidden" value={@image_url} />
        <.input
          field={@form[:persona_id]}
          type="select"
          label="Kitchen Persona"
          options={@persona_options}
          prompt="Select a persona"
        />
        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
      <.header class="text-center block my-2">
        OR
      </.header>
      <.auth_button social="facebook" method="register" />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{persona_id: nil})

    kitchen_personas = Personas.fetch_personas()
    persona_options = Enum.map(kitchen_personas, &{&1.name, &1.id})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(:image_url, nil)
      |> assign(:persona_options, persona_options)
      |> assign(:kitchen_personas, kitchen_personas)
      |> assign(:current_persona, nil)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)

    current_persona =
      Enum.find(
        socket.assigns.kitchen_personas,
        &("#{&1.id}" == user_params["persona_id"])
      )

    {:noreply,
     assign(socket, :current_persona, current_persona)
     |> assign_form(Map.put(changeset, :action, :validate))}
  end

  def handle_event("image_uploaded", %{"url" => url}, socket) do
    {:noreply, assign(socket, :image_url, url)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
