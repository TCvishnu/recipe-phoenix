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
          case repo.get(Recipe, recipe_id) do
            nil ->
              repo.rollback("Recipe not found")

            recipe ->
              current_rating = recipe.rating || 0
              total_count = recipe.total_ratings + 1
              new_rating = (current_rating * (total_count - 1) + rating) / total_count

              case recipe
                   |> Ecto.Changeset.change(%{rating: new_rating, total_ratings: total_count})
                   |> repo.update() do
                {:ok, _updated_recipe} ->
                  { inserted_rating, new_rating}

                {:error, _changeset} ->
                  repo.rollback("Failed to update recipe rating")
              end
          end

        {:error, error_changeset} ->
          repo.rollback(error_changeset)
      end
    end) do
      {:ok, {inserted_rating, new_rating}} ->
        conn
        |> put_status(:created)
        |> json(%{rating: inserted_rating, new_rating: new_rating})

      {:error, error_message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: error_message})
    end
  end


  def has_rated?(conn, %{"recipe_id" => recipe_id}) do
    user = conn.assigns[:current_user]

    case Rating
    |> where([r], r.user_id == ^user.id)
    |> where([r], r.recipe_id == ^recipe_id)
    |> Repo.one() do
      nil ->
        conn
        |> json(%{has_rated: false})
      _rating ->
        conn
        |> json(%{has_rated: true})
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} ->
      msg
    end)
  end
end
