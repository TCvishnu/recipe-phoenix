defmodule Recipe.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false


  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :recipes, Recipe.Recipe
    has_many :recent_recipes, Recipe.RecentRecipe

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end

  defimpl Jason.Encoder, for: Recipe.Accounts.User do
    def encode(user, opts) do
      %{
        id: user.id,
        email: user.email,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      }
      |> Jason.Encode.map(opts)
    end
  end
end
