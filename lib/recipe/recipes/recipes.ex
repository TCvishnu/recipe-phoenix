defmodule RecipeServices do
  alias Recipe.Repo
  alias Recipe.Recipe
  import Ecto.Query

  def list_recipes_paginated(page, page_size) do
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

  def list_all_user_recipes(user_id) do
    recipes = Recipe
    |> select([r], %{
      id: r.id,
      name: r.name,
      rating: r.rating,
      is_veg: r.is_veg,
      preparation_time: r.preperation_time,
      steps_count: fragment("array_length(?, 1)", r.steps)
    })
    |> where([r], r.user_id == ^user_id)
    |> Repo.all()

    recipes
  end

  def search_recipes(liketerm) do
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

  def search_recipes_by_tags(tags) do
    Recipe
    |> where([r], fragment("? && ?", r.tags, ^tags))
    |> Repo.all()
  end

  def fetch_recipe_by_id(recipe_id) do
    Repo.get(Recipe, recipe_id)
  end

  def insert_one_recipe(recipe_params) do
    Repo.insert(Recipe.changeset(%Recipe{}, recipe_params))
  end

  def delete_recipe(recipe) do
    Repo.delete(recipe)
  end

  def update_recipe(recipe, recipe_params) do
    Repo.update(Recipe.changeset(recipe, recipe_params))
  end
end
