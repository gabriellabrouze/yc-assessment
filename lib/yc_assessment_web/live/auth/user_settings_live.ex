defmodule YCWeb.UserSettingsLive do
  alias YC.Personas
  use YCWeb, :live_view

  alias YC.Accounts
  alias YC.Accounts.User
  alias YCWeb.UploadWidgetComponent

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">
      <div>
        <.simple_form
          for={@profile_form}
          id="profile_form"
          phx-submit="update_profile"
          phx-change="validate_profile"
        >
          <.live_component
            module={UploadWidgetComponent}
            id="upload-widget"
            image_url={@image_url}
            persona={@current_persona}
          />
          <.input field={@profile_form[:picture]} type="hidden" value={@image_url} />
          <.input field={@profile_form[:given_name]} type="text" label="First Name" required />
          <.input field={@profile_form[:family_name]} type="text" label="Last Name" required />

          <.input
            field={@profile_form[:persona_id]}
            type="select"
            label="Kitchen Persona"
            options={@persona_options}
            prompt="Select a persona"
          />
          <:actions>
            <.button phx-disable-with="Changing...">Update Profile</.button>
          </:actions>
        </.simple_form>
      </div>

      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    user_changeset = User.update_profile_changeset(user)
    kitchen_personas = Personas.fetch_personas()
    persona_options = Personas.fetch_options()
    current_persona = Enum.find(kitchen_personas, &(&1.id == user.persona_id))

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:image_url, user.picture)
      |> assign(:persona_options, persona_options)
      |> assign(:kitchen_personas, kitchen_personas)
      |> assign(:current_persona, current_persona)
      |> assign(:profile_form, to_form(user_changeset))

    {:ok, socket}
  end

  def handle_event("validate_profile", %{"user" => profile_params}, socket) do
    IO.inspect("VALIDATE PRO")

    current_persona =
      Enum.find(
        socket.assigns.kitchen_personas,
        &("#{&1.id}" == profile_params["persona_id"])
      )
      |> IO.inspect()

    profile_form =
      socket.assigns.current_user
      |> User.update_profile_changeset(profile_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply,
     assign(socket, profile_form: profile_form)
     |> assign(:current_persona, current_persona)}
  end

  def handle_event("update_profile", %{"user" => profile_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user_profile(user, profile_params) do
      {:ok, _user} ->
        {:noreply, socket |> put_flash(:info, "Updated Profile")}

      {:error, changeset} ->
        {:noreply, assign(socket, :profile_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("image_uploaded", %{"url" => url}, socket) do
    {:noreply, assign(socket, :image_url, url)}
  end
end
