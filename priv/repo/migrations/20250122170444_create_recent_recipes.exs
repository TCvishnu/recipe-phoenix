defmodule Recipe.Repo.Migrations.CreateRecentRecipes do
  use Ecto.Migration

  def change do
    create table(:recent_recipes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :recipe_id, references(:recipes, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:recent_recipes, [:user_id])
    create index(:recent_recipes, [:recipe_id])
  end
end
