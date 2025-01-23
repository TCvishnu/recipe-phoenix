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
        updated_at: comment.updated_at,
        replies: encode_replies(comment.replies, opts),
        user: encode_user(comment.user, opts)
      }
      |> Jason.Encode.map(opts)
    end

    defp encode_replies(replies, opts) when is_list(replies) do
      Enum.map(replies, fn reply ->
        %{
          updated_at: reply.updated_at,
          reply: encode_nested_reply(reply.reply, opts)
        }
      end)
    end

    defp encode_replies(_replies, _opts), do: nil

    defp encode_nested_reply(%Recipe.Comment{} = nested_reply, opts) do
      %{
        id: nested_reply.id,
        text: nested_reply.text,
        user: encode_user(nested_reply.user, opts),
        updated_at: nested_reply.updated_at
      }
    end

    defp encode_nested_reply(nil, _opts), do: nil

    defp encode_user(%Recipe.Accounts.User{} = user, _opts) do
      %{
        email: user.email,
        updated_at: user.updated_at
      }
    end

    defp encode_user(nil, _opts), do: nil
  end

end
