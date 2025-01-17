defmodule Recipe.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string
      add :ingredients, {:array, :string}
      add :steps, {:array, :string}
      add :images, {:array, :string}
      add :is_veg, :boolean, default: false, null: false
      add :tags, {:array, :string}
      add :rating, :float
      add :preperation_time, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
