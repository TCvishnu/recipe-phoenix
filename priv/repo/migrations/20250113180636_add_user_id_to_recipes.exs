defmodule Recipe.Repo.Migrations.AddUserIdToRecipes do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end

    create index(:recipes, [:user_id])
  end
end
