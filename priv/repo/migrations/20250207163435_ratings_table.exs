defmodule Recipe.Repo.Migrations.RatingsTable do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :recipe_id, references(:recipes, on_delete: :delete_all)
      add :rating, :integer

      timestamps()
    end

    create unique_index(:ratings, [:user_id, :recipe_id])
  end

end
