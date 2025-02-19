defmodule YCWeb.FacebookAuthController do
  use YCWeb, :controller
  alias YCWeb.FacebookAuth

  def request(conn, _params) do
    FacebookAuth.request(conn)
  end

  def callback(conn, _params) do
    FacebookAuth.callback(conn)
  end
end
