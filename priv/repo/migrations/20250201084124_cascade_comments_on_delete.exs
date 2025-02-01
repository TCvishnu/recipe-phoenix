defmodule Recipe.Repo.Migrations.CascadeCommentsOnDelete do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      remove :recipe_id
    end
    alter table(:comments) do
      add :recipe_id, references(:recipes, on_delete: :delete_all)
    end
  end
end
