defmodule Recipe.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :rating, :integer
    belongs_to :user, Recipe.Accounts.User
    belongs_to :recipe, Recipe.Recipe

    timestamps()
  end

  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:user_id, :recipe_id, :rating])
    |> validate_required([:user_id, :recipe_id, :rating])
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> unique_constraint([:user_id, :recipe_id], message: "User already rated the recipe")
  end

  defimpl Jason.Encoder, for: Recipe.Rating do
    def encode(%Recipe.Rating{} = rating, opts) do
      %{
        id: rating.id,
        rating: rating.rating,
        user_id: rating.user_id,
        recipe_id: rating.recipe_id
      }
      |> Jason.Encode.map(opts)
    end
  end
end
