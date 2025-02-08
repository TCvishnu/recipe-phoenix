defmodule RecipeWeb.RatingsController do
  use RecipeWeb, :controller
  alias Recipe.Repo
  alias Recipe.Rating
  alias Recipe.Recipe
  import Ecto.Query

  def index(conn, %{"recipe_id" => recipe_id}) do
    ratings = Rating
    |> where([r], r.recipe_id == ^recipe_id)
    |> Repo.all()
    json(conn, %{ratings: ratings})
  end

  def create(conn, %{"recipe_id" => recipe_id, "rating" => rating}) do
    user = conn.assigns[:current_user]
    attrs = %{recipe_id: recipe_id, rating: rating, user_id: user.id}

    changeset = Rating.changeset(%Rating{}, attrs)

    case Repo.transaction(fn repo ->
      case repo.insert(changeset) do
        {:ok, inserted_rating} ->
          case repo.get_by(Recipe, id: recipe_id) do
            nil ->
              repo.rollback("Recipe not found")
            recipe ->
              avg_recipe_rating = calculate_avg_rating(repo, recipe_id)

              recipe
              |> Ecto.Changeset.change(rating: avg_recipe_rating)
              |> repo.update()
          end
        inserted_rating

        {:error, error_changeset} ->
          repo.rollback(error_changeset)
      end
    end) do
      {:ok, inserted_rating} ->
        conn
        |> put_status(:created)
        |> json(%{rating: inserted_rating})
      {:error, error_changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: format_changeset_errors(error_changeset)})
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} ->
      msg
    end)
  end

  defp calculate_avg_rating(repo, recipe_id) do
    ratings = Rating
    |> where([r], r.recipe_id == ^recipe_id)
    |> repo.all()

    Enum.reduce(ratings, 0, fn rating, acc -> rating.rating + acc end) / length(ratings)
  end
end
