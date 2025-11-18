defmodule LunchNinja.Repo do
  use Ecto.Repo,
    otp_app: :lunch_ninja,
    adapter: Ecto.Adapters.Postgres
end
