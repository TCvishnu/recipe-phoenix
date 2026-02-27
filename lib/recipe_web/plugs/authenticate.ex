defmodule RecipeWeb.Plug.Authenticate do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- Recipe.Token.verify(token) do
      assign(conn, :current_user, Recipe.Accounts.get_user(data.user_id))
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()
    end
  end
end
