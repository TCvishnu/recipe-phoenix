defmodule Recipe.Repo.Migrations.RemoveParentIdFromComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      remove :parent_comment_id
    end
  end
end
