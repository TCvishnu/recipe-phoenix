defmodule RecipeWeb.CommentsController do
  use RecipeWeb, :controller

  alias Recipe.Repo
  alias CommentServices
  alias Authorizer

  def index(conn, %{"recipe_id" => recipe_id}) do
    comments = CommentServices.get_comments_by_recipe_id(recipe_id)
    json(conn, %{comments: comments})
  end


  def show(conn, %{"id" => id}) do
    case CommentServices.get_comment_by_id(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Comment not found"})

      comment ->
        json(conn, %{comment: comment})
    end
  end

  def create(conn, %{"comment" => comment_params, "recipe_id" => recipe_id, "reply" => reply}) do
    user_id = conn.assigns.current_user.id
    comment_params =
      comment_params
      |> Map.put("recipe_id", recipe_id)
      |> Map.put("user_id", user_id)

    is_reply = String.downcase(reply) == "true"
    case Repo.transaction(CommentServices.insert_comment(comment_params, is_reply)) do

      {:ok, %{comment: inserted_comment, reply: reply}} ->
        comment = CommentServices.load_comment_and_its_replies(inserted_comment.id)
        json(conn, %{comment: comment, reply: reply})

      {:ok, %{comment: inserted_comment}} ->
        comment = CommentServices.load_comment_and_its_replies(inserted_comment.id)
        json(conn, %{comment: comment})

      {:error, _operation, changeset, _changes_so_far} ->
        json(conn, %{message: "Failed to add comment", errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

  def delete(conn, %{"id" => id}) do
    case CommentServices.get_comment_by_id(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Comment not found"})
      comment ->
          if(!Authorizer.can?(conn, comment)) do
            conn
            |> put_status(:forbidden)
            |> json(%{error: "Cannot delete comment of another user"})
          end
          case CommentServices.delete_comment(comment) do
            {:ok, _comment} ->
              conn
              |> put_status(:no_content)
              |> json(%{message: "Comment deleted succesfully"})
            {:error, _changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{message: "Failed to delete comment"})
          end
    end

  end
end
