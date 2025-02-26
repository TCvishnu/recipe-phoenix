defmodule RecipeWeb.RecipeController do
  use RecipeWeb, :controller

  alias RecipeServices
  alias Authorizer

  def index(conn, %{"page" => page, "size" => size}) do
    page = String.to_integer(page)
    page_size = String.to_integer(size)
    recipes = RecipeServices.list_recipes_paginated(page, page_size)

    json(conn, %{recipes: recipes})
  end

  def index(conn, %{ "q" => search_term}) do
    liketerm = "%#{search_term}%"
    recipes = RecipeServices.search_recipes(liketerm)
    json(conn, %{recipes: recipes})
  end

  def index(conn, %{"tag" => tags}) do
    case RecipeServices.search_recipes_by_tags(tags) do
      nil ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "No recipes found"})
      recipes ->
        conn
          |> put_status(:ok)
          |> json(%{recipes: recipes})
    end
  end

  def index(conn, _params) do
    recipes = RecipeServices.list_all_user_recipes(conn.assigns.current_user.id)
    json(conn, %{recipes: recipes})
  end

  def show(conn, %{"id" => id}) do
    case RecipeServices.fetch_recipe_by_id(id) do
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
    recipe_params = Map.put(recipe_params, "user_id", conn.assigns.current_user.id)

    case RecipeServices.insert_one_recipe(recipe_params) do
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
    case RecipeServices.fetch_recipe_by_id(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Recipe not found"})
      recipe ->
        if (!Authorizer.can?(conn, recipe)) do
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Cannot Update another user recipe"})
        end

        case RecipeServices.update_recipe(recipe, recipe_params) do
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
    case RecipeServices.fetch_recipe_by_id(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Recipe not found"})

      recipe ->
        if (!Authorizer.can?(conn, recipe)) do
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Cannot Delete another user recipe"})
        end

        case RecipeServices.delete_recipe(recipe) do
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
end
