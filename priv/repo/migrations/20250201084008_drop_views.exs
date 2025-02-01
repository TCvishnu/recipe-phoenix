defmodule Recipe.Repo.Migrations.DropViews do
  use Ecto.Migration

  def change do
    execute("DROP VIEW IF EXISTS replies_view")
    execute("DROP VIEW IF EXISTS top_comments")
    execute("DROP VIEW IF EXISTS replies_view2")
  end
end
