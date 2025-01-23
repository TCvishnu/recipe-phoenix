defmodule RecipeWeb.RecentRecipeController do
  use RecipeWeb, :controller

  alias Recipe.{Repo, RecentRecipe}
  import Ecto.Query

  def index(conn, _params) do
    user = conn.assigns[:current_user]
    recent_recipes =
    RecentRecipe
    |> where([r], r.user_id == ^user.id)
    |> order_by([r], desc: r.updated_at)
    |> preload(:recipe)
    |> Repo.all()

    recent_recipes = Enum.map(recent_recipes, fn recent_recipe ->
      %{
        id: recent_recipe.id,
        recipe: %{
          id: recent_recipe.recipe.id,
          name: recent_recipe.recipe.name,
          is_veg: recent_recipe.recipe.is_veg,
          preparation_time: recent_recipe.recipe.preperation_time,
          rating: recent_recipe.recipe.rating,
          steps_count: length(recent_recipe.recipe.steps)
        }
      }
    end)
    json(conn, %{"recentRecipes" => recent_recipes})
  end

  def create(conn, %{"recipe_id" => recipe_id}) do
    user = conn.assigns[:current_user]

    case search_recent_recipe(user.id, recipe_id) do
      nil ->
        if count_recent_recipes_of_user(user.id) == 5 do
          case find_oldest_recent_recipe_of_user(user.id) do
            least_recent ->
              Repo.transaction(fn ->
                Repo.delete!(least_recent)
                insert_recent_recipe(user.id, recipe_id)
              end)
              |> case do
                {:ok, _} ->
                  conn
                  |> put_status(:created)
                  |> json(%{message: "Recent recipe added successfully"})
                {:error, reason} ->
                  conn
                  |> put_status(:unprocessable_entity)
                  |> json(%{error: "Transaction failed: #{reason}"})
              end
          end
        else
          insert_recent_recipe(user.id, recipe_id)
          conn
          |> put_status(:created)
          |> json(%{message: "Recent recipe added successfully"})
        end

      recent_recipe ->
        update_updated_at(recent_recipe)
        conn
        |> json(%{message: "Recent recipe updated"})
    end
  end

  defp insert_recent_recipe(user_id, recipe_id) do
    recent_recipe_changeset = RecentRecipe.changeset(%RecentRecipe{}, %{user_id: user_id, recipe_id: recipe_id})
    Repo.insert!(recent_recipe_changeset)
  end

  defp search_recent_recipe(user_id, recipe_id) do
    Repo.get_by(RecentRecipe, user_id: user_id, recipe_id: recipe_id)
  end

  defp count_recent_recipes_of_user(user_id) do
    RecentRecipe
    |> where([r], r.user_id == ^user_id)
    |> select([r], count(r.id))
    |> Repo.one()
  end

  defp find_oldest_recent_recipe_of_user(user_id) do
    RecentRecipe
    |> where([r], r.user_id == ^user_id)
    |> order_by([r], asc: r.updated_at)
    |> limit(1)
    |> Repo.one()
  end

  defp update_updated_at(recent_recipe) do
    date_time = DateTime.utc_now()
    date_time = DateTime.truncate(date_time, :second)
    changeset = Ecto.Changeset.change(recent_recipe, updated_at: date_time)
    Repo.update(changeset)
  end

end
