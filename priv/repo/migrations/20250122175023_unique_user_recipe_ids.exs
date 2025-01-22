defmodule Recipe.Repo.Migrations.UniqueUserRecipeIds do
  use Ecto.Migration

  def change do
    create unique_index(:recent_recipes, [:user_id, :recipe_id])
  end
end
