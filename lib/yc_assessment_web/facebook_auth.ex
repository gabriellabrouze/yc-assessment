defmodule YCWeb.FacebookAuth do
  import Plug.Conn

  alias Assent.Strategy.Facebook
  alias YC.Accounts.User

  # http://localhost:4000/auth/facebook
  def request(conn) do
    Application.get_env(:assent, :facebook)
    |> Facebook.authorize_url()
    |> IO.inspect(label: "authorize_url")
    |> case do
      {:ok, %{url: url, session_params: session_params}} ->
        conn = put_session(conn, :session_params, session_params)

        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, error} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(
          500,
          "Something went wrong generating the request authorization url: #{inspect(error)}"
        )
    end
  end

  # http://localhost:4000/auth/facebook/callback
  def callback(conn) do
    %{params: params} = fetch_query_params(conn)
    session_params = get_session(conn, :session_params)

    Application.get_env(:assent, :facebook)
    |> Keyword.put(:session_params, session_params)
    |> Facebook.callback(params)
    |> IO.inspect(label: "callback params")
    |> case do
      {:ok, %{user: user, token: token}} ->
        # Authorization succesful
        IO.inspect({user, token}, label: "user and token")

        user_record = YC.Accounts.get_user_by_email_or_register(user)

        conn
        |> YCWeb.UserAuth.log_in_user(user_record)
        # |> put_session(:facebook_user, user)
        # |> put_session(:facebook_user_token, token)
        |> Phoenix.Controller.redirect(to: "/")

      {:error, error} ->
        # Authorizaiton failed
        IO.inspect(error, label: "error")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, inspect(error, pretty: true))
    end
  end

  def fetch_facebook_user(conn, _opts) do
    with user when is_map(user) <- get_session(conn, :facebook_user) do
      assign(conn, :current_user, %User{email: user["email"]})
    else
      _ -> conn
    end
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user = session["facebook_user"] do
        %User{email: user["email"]}
      end
    end)
  end
end

# callback params: {:ok,
#  %{
#    user: %{
#      "email" => "gabibro@hotmail.com",
#      "family_name" => "Brouze",
#      "given_name" => "Gabi",
#      "name" => "Gabi Brouze",
#      "picture" => "https://graph.facebook.com/v4.0/10161287180667967/picture",
#      "sub" => "10161287180667967"
#    },
#    token: %{
#      "access_token" => "EAAZApgVlOd8cBO6ytRGoSlGeADfqVwtQbZBBYPbzO2PLJakkDd9GEGakgu7VsxbaCliZBgdJchE8YP53fl9Ok7WYeR0j6uZBSrybZAkaoIIQHI9o8Urn5OvsRZBWImk7tUxYUM03LEUyX4bsGJkeSeyv8i3IAbT8WhWkGUFVOzZABDZBIZAQbqd9fQwboGZA1kDuwu0wM8MAryzZATl4WWzPsfn8hZCEqShB0xGdbovHhPiwKQLurmcsvAZDZD",
#      "expires_in" => 5162731,
#      "token_type" => "bearer"
#    }
#  }}
# user and token: {%{
#    "email" => "gabibro@hotmail.com",
#    "family_name" => "Brouze",
#    "given_name" => "Gabi",
#    "name" => "Gabi Brouze",
#    "picture" => "https://graph.facebook.com/v4.0/10161287180667967/picture",
#    "sub" => "10161287180667967"
#  },
#  %{
#    "access_token" => "EAAZApgVlOd8cBO6ytRGoSlGeADfqVwtQbZBBYPbzO2PLJakkDd9GEGakgu7VsxbaCliZBgdJchE8YP53fl9Ok7WYeR0j6uZBSrybZAkaoIIQHI9o8Urn5OvsRZBWImk7tUxYUM03LEUyX4bsGJkeSeyv8i3IAbT8WhWkGUFVOzZABDZBIZAQbqd9fQwboGZA1kDuwu0wM8MAryzZATl4WWzPsfn8hZCEqShB0xGdbovHhPiwKQLurmcsvAZDZD",
#    "expires_in" => 5162731,
#    "token_type" => "bearer"
#  }}
