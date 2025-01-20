defmodule Recipe.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :text, :string

    belongs_to :recipe, Recipe.Recipe
    belongs_to :user, Recipe.Accounts.User

    has_many :replies, Recipe.Reply, foreign_key: :main_comment_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:text, :recipe_id, :user_id])
    |> validate_required([:text, :recipe_id, :user_id])
    |> validate_length(:text, min: 1)
  end

  defimpl Jason.Encoder, for: Recipe.Comment do
  def encode(%Recipe.Comment{} = comment, opts) do
    %{
      id: comment.id,
      text: comment.text,
      recipe_id: comment.recipe_id,
      user_id: comment.user_id,
      inserted_at: comment.inserted_at,
      updated_at: comment.updated_at,
      replies: encode_replies(comment.replies, opts),
      user: encode_user(comment.user, opts)
    }
    |> Jason.Encode.map(opts)
  end

  # Helper function to encode replies
  defp encode_replies(replies, opts) when is_list(replies) do
    Enum.map(replies, fn reply ->
      %{
        id: reply.id,
        reply_comment_id: reply.reply_comment_id,
        main_comment_id: reply.main_comment_id,
        inserted_at: reply.inserted_at,
        updated_at: reply.updated_at,
        reply: encode_nested_reply(reply.reply, opts)
      }
    end)
  end

  defp encode_replies(_replies, _opts), do: nil

  # Helper function to encode nested reply comments
  defp encode_nested_reply(%Recipe.Comment{} = nested_reply, opts) do
    %{
      id: nested_reply.id,
      text: nested_reply.text,
      recipe_id: nested_reply.recipe_id,
      user_id: nested_reply.user_id,
      user: encode_user(nested_reply.user, opts),
      inserted_at: nested_reply.inserted_at,
      updated_at: nested_reply.updated_at
    }
  end

  defp encode_nested_reply(nil, _opts), do: nil

  # Helper function to encode the user
  defp encode_user(%Recipe.Accounts.User{} = user, opts) do
    %{
      id: user.id,
      email: user.email,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp encode_user(nil, _opts), do: nil
end

end
