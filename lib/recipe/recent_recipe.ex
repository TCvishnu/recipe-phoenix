defmodule Recipe.RecentRecipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recent_recipes" do

    belongs_to :user, Recipe.Accounts.User
    belongs_to :recipe, Recipe.Recipe

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recent_recipe, attrs) do
    recent_recipe
    |> cast(attrs, [:user_id, :recipe_id])
    |> validate_required([:user_id, :recipe_id])
  end

  defimpl Jason.Encoder, for: Recipe.RecentRecipe do
    def encode(%Recipe.RecentRecipe{} = recent_recipe, opts) do
      %{
        id: recent_recipe.id,
        recipe: encode_recipe(recent_recipe.recipe, opts)
      }
      |>Jason.Encode.map(opts)
    end

    defp encode_recipe(recipe, _opts) do
    %{
      id: recipe.recipe_id,
      name: recipe.name,
      is_veg: recipe.is_veg,
      rating: recipe.rating,
      preperation_time: recipe.preperation_time,
      steps_count: length(recipe.steps)
    }
    end
  end
end
