defmodule MessagingServiceWeb.ConversationController do
  use MessagingServiceWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias MessagingService.Messaging
  alias MessagingServiceWeb.Schemas.{ConversationResponse, MessageResponse, ErrorResponse}
  alias OpenApiSpex.Schema

  action_fallback MessagingServiceWeb.FallbackController

  tags ["Conversations"]

  operation :index,
    summary: "List all conversations",
    parameters: [],
    responses: [
      ok:
        {"Conversations list", "application/json",
         %Schema{type: :array, items: ConversationResponse}}
    ]

  def index(conn, _params) do
    conversations = Messaging.list_conversations()

    conn
    |> put_status(:ok)
    |> json(Enum.map(conversations, &render_conversation/1))
  end

  operation :messages,
    summary: "Get messages for a conversation",
    parameters: [
      id: [in: :path, type: :integer, description: "Conversation ID", required: true]
    ],
    responses: [
      ok: {"Messages list", "application/json", %Schema{type: :array, items: MessageResponse}},
      not_found: {"Conversation not found", "application/json", ErrorResponse}
    ]

  def messages(conn, %{"id" => id}) do
    # Path params are not converted by BetterParams, so "id" is still a string
    conversation_id = String.to_integer(id)
    messages = Messaging.list_conversation_messages(conversation_id)

    conn
    |> put_status(:ok)
    |> json(Enum.map(messages, &render_message/1))
  end

  defp render_conversation(conversation) do
    %{
      id: conversation.id,
      participants_key: conversation.participants_key,
      participants: conversation.participants,
      messages: Enum.map(conversation.messages, &render_message/1),
      inserted_at: conversation.inserted_at,
      updated_at: conversation.updated_at
    }
  end

  defp render_message(message) do
    %{
      id: message.id,
      conversation_id: message.conversation_id,
      from: message.from,
      to: message.to,
      type: message.type,
      body: message.body,
      attachments: message.attachments,
      provider_id: message.provider_id,
      direction: message.direction,
      message_timestamp: message.message_timestamp,
      inserted_at: message.inserted_at,
      updated_at: message.updated_at
    }
  end
end
