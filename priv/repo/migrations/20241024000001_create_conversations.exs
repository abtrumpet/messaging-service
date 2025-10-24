defmodule MessagingService.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :participants_key, :string, null: false
      add :participants, {:array, :string}, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:conversations, [:participants_key])
    create index(:conversations, [:participants], using: :gin)
  end
end
