defmodule Recipe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ets.new(:token_blacklist, [:set, :public, :named_table])
    children = [
      RecipeWeb.Telemetry,
      Recipe.Repo,
      {DNSCluster, query: Application.get_env(:recipe, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Recipe.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Recipe.Finch},
      # Start a worker by calling: Recipe.Worker.start_link(arg)
      # {Recipe.Worker, arg},
      # Start to serve requests, typically the last entry
      RecipeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Recipe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RecipeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
