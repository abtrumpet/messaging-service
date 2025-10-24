defmodule MessagingService.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :conversation_id, references(:conversations, on_delete: :delete_all), null: false
      add :from, :string, null: false
      add :to, :string, null: false
      add :type, :string, null: false
      add :body, :text
      add :attachments, {:array, :string}
      add :provider_id, :string
      add :direction, :string, null: false
      add :message_timestamp, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:conversation_id])
    create index(:messages, [:from])
    create index(:messages, [:to])
    create index(:messages, [:message_timestamp])
    create index(:messages, [:provider_id])
  end
end
