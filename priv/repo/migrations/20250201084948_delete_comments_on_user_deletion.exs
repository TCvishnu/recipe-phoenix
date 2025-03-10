defmodule Recipe.Repo.Migrations.DeleteCommentsOnUserDeletion do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      remove :user_id
    end

    alter table(:comments) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
