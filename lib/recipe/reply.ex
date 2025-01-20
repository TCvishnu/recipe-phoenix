defmodule Recipe.Reply do
  use Ecto.Schema
  import Ecto.Changeset

  schema "replies" do

    belongs_to :reply, Recipe.Comment, foreign_key: :reply_comment_id
    belongs_to :comment, Recipe.Comment, foreign_key: :main_comment_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reply, attrs) do
    reply
    |> cast(attrs, [:main_comment_id, :reply_comment_id])
    |> validate_required([:main_comment_id, :reply_comment_id])
  end

  defimpl Jason.Encoder, for: Recipe.Reply do
    def encode(%Recipe.Reply{} = reply, opts) do
      %{
        id: reply.id,
        main_comment_id: reply.main_comment_id,
        reply_comment_id: reply.reply_comment_id,
        inserted_at: reply.inserted_at,
        updated_at: reply.updated_at
      }
      |> Jason.Encode.map(opts)
    end
  end
end
