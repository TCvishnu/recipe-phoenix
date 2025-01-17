defmodule Recipe.Repo do
  use Ecto.Repo,
    otp_app: :recipe,
    adapter: Ecto.Adapters.Postgres
end
