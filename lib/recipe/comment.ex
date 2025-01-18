defmodule Recipe.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :text, :string
    field :recipe_id, :id
    field :user_id, :id
    field :parent_comment_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:text])
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
        parent_comment_id: comment.parent_comment_id,
        inserted_at: comment.inserted_at,
        updated_at: comment.updated_at
      }
      |> Jason.Encode.map(opts)
    end
  end
end
