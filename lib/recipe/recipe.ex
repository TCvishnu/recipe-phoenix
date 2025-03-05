defmodule Recipe.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :name, :string
    field :ingredients, {:array, :map}
    field :steps, {:array, :string}
    field :image, :string
    field :is_veg, :boolean, default: false
    field :tags, {:array, :string}, default: []
    field :rating, :float, default: 0.0
    field :total_ratings, :integer, default: 0
    field :preperation_time, :integer

    belongs_to :user, Recipe.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :ingredients, :steps, :image, :is_veg, :tags, :rating, :preperation_time, :user_id, :total_ratings])
    |> validate_required([:name, :ingredients, :steps, :is_veg, :preperation_time, :user_id])
  end

  defimpl Jason.Encoder, for: Recipe.Recipe do
    def encode(%Recipe.Recipe{} = recipe, opts) do
      %{
        id: recipe.id,
        name: recipe.name,
        ingredients: recipe.ingredients,
        steps: recipe.steps,
        image: recipe.image,
        is_veg: recipe.is_veg,
        tags: recipe.tags,
        rating: recipe.rating,
        preperation_time: recipe.preperation_time,
        user_id: recipe.user_id,
        inserted_at: recipe.inserted_at,
        updated_at: recipe.updated_at
      }
      |> Jason.Encode.map(opts)
    end
  end

end
