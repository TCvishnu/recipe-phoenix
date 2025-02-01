defmodule RecipeWeb.CommentsController do
  use RecipeWeb, :controller

  alias Recipe.{Repo, Comment, Reply}
  import Ecto.Query

  def index(conn, %{"recipe_id" => recipe_id_in_params}) do
    case Integer.parse(recipe_id_in_params) do
      {recipe_id, _} ->
        comments = get_comments_by_recipe_id(recipe_id)
        IO.inspect(comments)
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

  def create(conn, %{"comment" => comment_params, "recipe_id" => recipe_id_params, "reply" => reply}) do
    case Integer.parse(recipe_id_params) do
      {recipe_id, _} ->
        user = conn.assigns[:current_user]
        comment_params = Map.put(comment_params, "recipe_id", recipe_id)
        comment_params = Map.put(comment_params, "user_id", user.id)

        reply = String.downcase(reply) == "true"

        Repo.transaction(fn ->
          comment_changeset = Comment.changeset(%Comment{}, comment_params)
          case Repo.insert(comment_changeset) do
            {:ok, comment} ->
              if reply do
                parent_comment_id = comment_params["parent_comment_id"]
                reply_changeset = Reply.changeset(%Reply{}, %{"main_comment_id" => parent_comment_id, "reply_comment_id" => comment.id})

                case Repo.insert(reply_changeset) do
                  {:ok, reply} ->
                    comment = Comment
                    |> where([c], c.id == ^comment.id)
                    |> preload([:user, replies: [:reply, reply: [:user]]])
                    |> Repo.one()

                    conn
                    |> put_status(:created)
                    |> json(%{comment: comment, reply: reply})
                  {:error, _reply_changeset_error} ->
                    Repo.rollback({:failed_insertion})
                    json(conn, %{error: "Replying error"})
                end
                json(conn, %{random: "random"});
              else
                comment = Comment
                |> where([c], c.id == ^comment.id)
                |> preload([:user, replies: [:reply, reply: [:user]]])
                |> Repo.one()

                conn
                |> put_status(:created)
                |> json(%{comment: comment})
              end
            {:error, _changeset} ->
              json(conn, %{error: "Comment insertion failed"})
          end
        end)

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid recipe id"})
    end
    json(conn, %{random: "random"})
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Comment, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Comment not found"})
      comment ->
        user = conn.assigns[:current_user]
        if(comment.user_id != user.id) do
          conn
          |> put_status(:unauthorized)
          |> json(%{message: "Cannot delete someones else's comment"})
        end
        case Repo.delete(comment) do
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

  defp get_comments_by_recipe_id(recipe_id) do
    reply_comment_ids_query =
      from(r in Recipe.Reply,
        select: r.reply_comment_id
      )

    Comment
    |> where([c], c.recipe_id == ^recipe_id)
    |> where([c], c.id not in subquery(reply_comment_ids_query))
    |> preload([:user, replies: [:reply, reply: [:user]]])
    |> Repo.all()
  end


end
