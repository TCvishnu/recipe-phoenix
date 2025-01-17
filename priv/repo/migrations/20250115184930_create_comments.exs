defmodule Recipe.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :string
      add :recipe_id, references(:recipes, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :parent_comment_id, references(:comments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:recipe_id])
    create index(:comments, [:user_id])
    create index(:comments, [:parent_comment_id])
  end
end
