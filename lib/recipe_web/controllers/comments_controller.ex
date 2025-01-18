defmodule RecipeWeb.CommentsController do
  use RecipeWeb, :controller

  alias Recipe.{Repo, Comment}
  import Ecto.Query

  def index(conn, %{"recipe_id" => recipe_id_in_params}) do
    case Integer.parse(recipe_id_in_params) do
      {recipe_id, _} ->
        comments =
          Comment
          |> where([c], c.recipe_id == ^recipe_id)
          |> order_by([c], asc: c.inserted_at)
          |> Repo.all()

        json(conn, %{comments: comments})

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid recipe_id"})
    end
  end


  def show(conn, %{"id" => id_param}) do
    case Integer.parse(id_param) do
      {id, _} ->
        case Repo.get(Comment, id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Comment not found"})

          comment ->
            json(conn, %{comment: comment})
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid comment id"})
    end
  end


  def create(conn, %{"comment" => comment_params}) do
    changeset = Comment.changeset(%Comment{}, comment_params)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        conn
        |> put_status(:created)
        |> json(%{comment: comment})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

end
