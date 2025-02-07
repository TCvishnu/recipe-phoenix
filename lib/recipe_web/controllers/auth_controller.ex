defmodule RecipeWeb.AuthController do
  use RecipeWeb, :controller
  alias Recipe.Accounts



  def register(conn, %{"email" => email, "password" => password}) do
    case Accounts.create_user(%{email: email, password: password}) do
      {:ok, user} ->
        json(conn, %{message: "User created successfully", user: user})

      {:error, changeset} ->
        errors = format_changeset_errors(changeset)
        conn
        |> put_status(:bad_request)
        |> json(%{error: errors})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = Recipe.Token.sign(%{user_id: user.id})
        json(conn, %{message: "Login successful", user: user, token: token})

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})
    end
  end

  def verify(conn, _params) do
    current_user = conn.assigns[:current_user]
    json(conn, %{status: "ok", user: current_user})
  end

  def logout(conn, _params) do
    token = get_req_header(conn, "authorization") |> List.first()
    case token do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Token not found, cannot logout"})
      token ->
        Recipe.Token.revoke(token)
        conn
        |> json(%{message: "Logout successful"})
    end
  end

  def forgot_password(conn, %{"email" => email}) do
    case Accounts.get_user_by_email(email) do
      {:ok, user} ->
        token = Recipe.Token.sign(user.id)
        expires_at = Timex.now() |> Timex.add(Timex.Duration.from_minutes(15))

        changeset = Accounts.User.changeset(user, %{
          reset_token: token,
          reset_token_expires_in: expires_at
        })
        IO.inspect(changeset)

        case Recipe.Repo.update(changeset) do
          {:ok, _updated_user} ->
            Recipe.Emails.forgot_password_email(user, token)
            conn
            |> put_status(:reset_content)
            |> json(%{message: "Reset password mail sent"})
          {:error, error_changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{message: "Failed to set reset token", error: format_changeset_errors(error_changeset)})
        end

      {:error, reason} ->
        conn
        |> put_status(reason)
        |> json(%{message: "Invalid mail id"})
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} ->
      msg
    end)
  end
end
