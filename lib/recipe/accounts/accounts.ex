defmodule Recipe.Accounts do
  alias Recipe.Repo
  alias Recipe.Accounts.User
  alias Bcrypt

  def authenticate_user(email, password) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :user_not_found}
      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_password}
        end
    end
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id) do
    case Repo.get_by(User, id: id) do
      nil -> {:error, :user_not_found}
      user -> user
    end
  end

  def get_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end
end
