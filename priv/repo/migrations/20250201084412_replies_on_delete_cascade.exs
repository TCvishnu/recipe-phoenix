defmodule Recipe.Repo.Migrations.RepliesOnDeleteCascade do
  use Ecto.Migration

  def change do
    alter table(:replies) do
      remove :main_comment_id
    end
    alter table(:replies) do
      remove :reply_comment_id
    end

    alter table(:replies) do
      add :main_comment_id, references(:comments, on_delete: :delete_all)
    end
    alter table(:replies) do
      add :reply_comment_id, references(:comments, on_delete: :delete_all)
    end
  end
end
