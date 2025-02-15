defmodule RecipeWeb.RecipeController do
  use RecipeWeb, :controller

  alias Recipe.Repo
  alias Recipe.Recipe
  import Ecto.Query

  def index(conn, %{"page" => page, "size" => size}) do
    page = String.to_integer(page)
    page_size = String.to_integer(size)
    recipes = list_recipes_paginated(page, page_size)

    json(conn, %{recipes: recipes})
  end

  def index(conn, %{ "q" => search_term}) do
    liketerm = "%#{search_term}%"
    recipes = list_recipes_searched((liketerm))

    json(conn, %{recipes: recipes})
  end

  def index(conn, %{"tags" => tags}) do
    case Jason.decode(tags) do
      {:ok, parsed_tags} ->
        case Recipe
        |> where([r], fragment("? && ?", r.tags, ^parsed_tags))
        |> Repo.all() do
          nil ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "No recipes found"})
          recipes ->
            conn
            |> put_status(:ok)
            |> json(%{recipes: recipes})
        end
      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "invalid tags search format"})
      end
  end

  def index(conn, _params) do
    user = conn.assigns[:current_user]
    recipes = Recipe
    |> select([r], %{
      id: r.id,
      name: r.name,
      rating: r.rating,
      is_veg: r.is_veg,
      preparation_time: r.preperation_time,
      steps_count: fragment("array_length(?, 1)", r.steps)
    })
    |> where([r], r.user_id == ^user.id)
    |> Repo.all()
    json(conn, %{recipes: recipes})
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Recipe, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Recipe not found"})
      recipe ->
        conn
        |> json(%{recipe: recipe})
    end
  end

  def create(conn, %{"recipe" => recipe_params}) do
    user = conn.assigns[:current_user]
    recipe_params = Map.put(recipe_params, "user_id", user.id)
    recipe_params = Map.put(recipe_params, "rating", 0)
    recipe_params = Map.put(recipe_params, "total_ratings", 0)

    case Repo.insert(Recipe.changeset(%Recipe{}, recipe_params)) do
      {:ok, recipe} ->
        conn
        |> put_status(:created)
        |> json(%{recipe: recipe})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

  def update(conn, %{"id" => id, "recipe" => recipe_params}) do
    case Repo.get(Recipe, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Recipe not found"})
      recipe ->
        case Repo.update(Recipe.changeset(recipe, recipe_params)) do
          {:ok, updated_recipe} ->
            json(conn, recipe: updated_recipe)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Recipe, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Recipe not found"})

      recipe ->
        user = conn.assigns[:current_user]
        if(recipe.user_id != user.id) do
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Cannot delete another's user's recipe"})
        end
        case Repo.delete(recipe) do
          {:ok, _recipe} ->
            conn
            |> put_status(:no_content)
            |> json(%{message: "Deleted successfully"})

          {:error, _changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to delete recipe"})
        end
    end
  end

  defp list_recipes_paginated(page, page_size) do
    Recipe
    |> select([r], %{
      id: r.id,
      name: r.name,
      rating: r.rating,
      is_veg: r.is_veg,
      preparation_time: r.preperation_time,
      steps_count: fragment("array_length(?, 1)", r.steps)
    })
    |> limit(^page_size)
    |> offset(^((page - 1) * page_size))
    |> Repo.all()
  end

  defp list_recipes_searched(liketerm) do
    Recipe
    |> select([r], %{
      id: r.id,
      name: r.name,
      rating: r.rating,
      is_veg: r.is_veg,
      preparation_time: r.preperation_time,
      steps_count: fragment("array_length(?, 1)", r.steps)
    })
    |> where([r], ilike(r.name, ^liketerm))
    |> Repo.all()
  end


end
