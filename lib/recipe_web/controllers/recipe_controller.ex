defmodule RecipeWeb.RecipeController do
  use RecipeWeb, :controller

  alias Recipe.Repo
  alias Recipe.Recipe
  import Ecto.Query

  def index(conn, %{"page" => page, "size" => size, "q" => search_term }) do
    page = String.to_integer(page)
    page_size = String.to_integer(size)

    recipes = list_recipes_paginated(page, page_size)

    json(conn, %{recipes: recipes})
  end

  def index(conn, %{ "q" => search_term}) do
    liketerm = "%#{search_term}%"
    recipes =
      Recipe
      |> where([r], ilike(r.name, ^liketerm))
      |> Repo.all()

    json(conn, %{recipes: recipes})
  end

  def index(conn, _params) do
    recipes = Repo.all(Recipe)
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
        Repo.delete!(recipe)
        send_resp(conn, :no_content, "")
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
    |> order_by(desc: :inserted_at)
    |> limit(^page_size)
    |> offset(^((page - 1) * page_size))
    |> Repo.all()
  end


end
