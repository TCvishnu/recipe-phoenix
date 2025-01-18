defmodule Recipe.Repo.Migrations.UpdateIngredientsField do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :new_ingredients, {:array, :map}, default: []
    end

    flush()

    # Transform existing data to the new format
    execute("""
    UPDATE recipes
    SET new_ingredients = ARRAY(
      SELECT jsonb_build_object('name', ingredient, 'quantity', 1, 'unit', 'pcs')
      FROM unnest(ingredients) AS ingredient
    )
    """)

    flush()

    # Drop the old column and rename the new column
    alter table(:recipes) do
      remove :ingredients
      add :ingredients, {:array, :map}, default: []
    end

    flush()

    execute("""
    UPDATE recipes
    SET ingredients = new_ingredients
    """)

    alter table(:recipes) do
      remove :new_ingredients
    end
  end
end
