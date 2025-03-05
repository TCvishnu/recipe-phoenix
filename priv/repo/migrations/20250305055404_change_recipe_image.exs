defmodule Recipe.Repo.Migrations.ChangeRecipeImage do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      remove :images
    end

    alter table(:recipes) do
      add :image, :string
    end
  end
end
