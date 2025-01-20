defmodule Recipe.Repo.Migrations.CreateReplies do
  use Ecto.Migration

  def change do
    create table(:replies) do
      add :main_comment_id, references(:comments, on_delete: :nothing)
      add :reply_comment_id, references(:comments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:replies, [:main_comment_id])
    create index(:replies, [:reply_comment_id])
  end
end
