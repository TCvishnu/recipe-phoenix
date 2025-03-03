defmodule CommentServices do
  alias Recipe.{Repo, Comment, Reply}
  import Ecto.Query
  alias Ecto.Multi

  def get_comments_by_recipe_id(recipe_id) do
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

  def get_comment_by_id(id) do
    Repo.get(Comment, id)
  end

  def delete_comment(comment) do
    Repo.delete(comment)
  end

  def insert_comment(comment_params, is_reply) do
    Multi.new()
    |> Multi.insert(:comment, Comment.changeset(%Comment{}, comment_params))
    |> check_and_insert_reply(is_reply, comment_params)
  end

  defp check_and_insert_reply(multi, is_reply, _main_comment_id) when not is_reply do
    multi
  end

  defp check_and_insert_reply(multi, _is_reply, comment_params) do
    parent_comment_id = comment_params["parent_comment_id"]
    Multi.insert(multi, :reply, fn %{comment: comment} ->
      Reply.changeset(%Reply{}, %{main_comment_id: parent_comment_id, reply_comment_id: comment.id})
    end)
  end

  def load_comment_and_its_replies(comment_id) do
    Comment
      |> where([c], c.id == ^comment_id)
      |> preload([:user, replies: [:reply, reply: [:user]]])
      |> Repo.one()
  end

end
