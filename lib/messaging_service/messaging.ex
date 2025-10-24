defmodule MessagingService.Messaging do
  @moduledoc """
  The Messaging context handles sending, receiving, and managing messages and conversations.
  Expects all parameters to already be atomized by BetterParams plug.
  """

  import Ecto.Query, warn: false
  alias MessagingService.Repo
  alias MessagingService.{Conversation, Message}
  alias MessagingService.Providers.{SmsProvider, EmailProvider}

  # Ensure these atoms exist for BetterParams to work with webhook fields
  @provider_id_fields [:messaging_provider_id, :xillio_id]

  @doc """
  Sends a message through the appropriate provider.
  All keys should be atoms.
  """
  def send_message(attrs) when is_map(attrs) do
    provider = get_provider(attrs.type)

    with {:ok, response} <- provider.send_message(attrs),
         {:ok, message} <- create_outbound_message(attrs, response) do
      {:ok, message}
    else
      {:error, :rate_limited} ->
        {:error, :rate_limited}

      {:error, :server_error} ->
        {:error, :server_error}

      {:error, :not_found} ->
        {:error, :not_found}

      {:error, :unauthorized} ->
        {:error, :unauthorized}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Receives an inbound message from a webhook.
  All keys should be atoms.
  """
  def receive_message(attrs) when is_map(attrs) do
    create_inbound_message(attrs)
  end

  @doc """
  Lists all conversations with their latest message.
  """
  def list_conversations do
    latest_message_query = from(m in Message, order_by: [desc: m.message_timestamp], limit: 1)

    Conversation
    |> preload(messages: ^latest_message_query)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  @doc """
  Gets a single conversation with all its messages.
  """
  def get_conversation!(id) do
    messages_query = from(m in Message, order_by: [asc: m.message_timestamp])

    Conversation
    |> preload(messages: ^messages_query)
    |> Repo.get!(id)
  end

  @doc """
  Lists all messages for a conversation.
  """
  def list_conversation_messages(conversation_id) do
    Message
    |> where([m], m.conversation_id == ^conversation_id)
    |> order_by(asc: :message_timestamp)
    |> Repo.all()
  end

  # Private functions

  defp get_provider(type) when type in [:sms, :mms], do: SmsProvider
  defp get_provider(:email), do: EmailProvider

  defp create_outbound_message(attrs, provider_response) do
    conversation = find_or_create_conversation(attrs.from, attrs.to)

    message_attrs = %{
      conversation_id: conversation.id,
      from: attrs.from,
      to: attrs.to,
      type: Atom.to_string(attrs.type),
      body: Map.get(attrs, :body),
      attachments: Map.get(attrs, :attachments),
      provider_id: provider_response[:provider_id],
      direction: "outbound",
      message_timestamp: parse_timestamp(Map.get(attrs, :timestamp))
    }

    %Message{}
    |> Message.changeset(message_attrs)
    |> Repo.insert()
  end

  defp create_inbound_message(attrs) do
    conversation = find_or_create_conversation(attrs.from, attrs.to)

    # Handle different provider ID field names (BetterParams converts string keys to atoms)
    # The @provider_id_fields module attribute ensures these atoms exist
    provider_id = attrs[:messaging_provider_id] || attrs[:xillio_id]

    message_attrs = %{
      conversation_id: conversation.id,
      from: attrs.from,
      to: attrs.to,
      type: Atom.to_string(attrs.type || :email),
      body: Map.get(attrs, :body),
      attachments: Map.get(attrs, :attachments),
      provider_id: provider_id,
      direction: "inbound",
      message_timestamp: parse_timestamp(Map.get(attrs, :timestamp))
    }

    %Message{}
    |> Message.changeset(message_attrs)
    |> Repo.insert()
  end

  defp find_or_create_conversation(from, to) do
    participants_key = Conversation.generate_participants_key(from, to)
    participants = Enum.sort([from, to])

    case Repo.get_by(Conversation, participants_key: participants_key) do
      nil ->
        %Conversation{}
        |> Conversation.changeset(%{
          participants_key: participants_key,
          participants: participants
        })
        |> Repo.insert!()

      conversation ->
        conversation
    end
  end

  defp parse_timestamp(nil), do: DateTime.utc_now()

  defp parse_timestamp(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> DateTime.utc_now()
    end
  end

  defp parse_timestamp(%DateTime{} = timestamp), do: timestamp
end
