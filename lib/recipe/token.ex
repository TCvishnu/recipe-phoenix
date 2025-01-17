defmodule Recipe.Token do
  @signing_salt "octosell_api"
  @token_age_secs 7 * 86_400
  @blacklist_table :token_blacklist

  @spec sign(map()) :: binary()

  def sign(data) do
    Phoenix.Token.sign(RecipeWeb.Endpoint, @signing_salt, data)
  end

  def revoke(token) do
    :ets.insert(@blacklist_table, {token, :revoked})
  end

  @spec verify(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify(token) do
    case Phoenix.Token.verify(RecipeWeb.Endpoint, @signing_salt, token, max_age: @token_age_secs) do

      {:ok, data} -> {:ok, data}
      _error -> {:error, :unauthenticated}
    end
  end
end
