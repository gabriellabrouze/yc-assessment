defmodule YC.Repo do
  use Ecto.Repo,
    otp_app: :yc_assessment,
    adapter: Ecto.Adapters.Postgres
end
