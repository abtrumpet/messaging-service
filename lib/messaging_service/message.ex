defmodule MessagingService.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :from, :string
    field :to, :string
    field :type, :string
    field :body, :string
    field :attachments, {:array, :string}
    field :provider_id, :string
    field :direction, :string
    field :message_timestamp, :utc_datetime

    belongs_to :conversation, MessagingService.Conversation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [
      :conversation_id,
      :from,
      :to,
      :type,
      :body,
      :attachments,
      :provider_id,
      :direction,
      :message_timestamp
    ])
    |> validate_required([:from, :to, :type, :direction, :message_timestamp])
    |> validate_inclusion(:type, ["sms", "mms", "email"])
    |> validate_inclusion(:direction, ["inbound", "outbound"])
    |> foreign_key_constraint(:conversation_id)
  end
end
