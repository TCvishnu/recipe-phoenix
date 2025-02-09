defmodule Recipe.Repo.Migrations.TotalRatingsCount do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :total_ratings, :integer
    end
  end
end
