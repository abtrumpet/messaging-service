defmodule MessagingServiceWeb.ConversationControllerTest do
  use MessagingServiceWeb.ConnCase

  alias MessagingService.Messaging

  setup do
    # Create some test messages to generate conversations
    {:ok, _msg1} =
      Messaging.send_message(%{
        "from" => "+12016661234",
        "to" => "+18045551234",
        "type" => "sms",
        "body" => "First message",
        "timestamp" => "2024-11-01T14:00:00Z"
      })

    {:ok, _msg2} =
      Messaging.send_message(%{
        "from" => "+18045551234",
        "to" => "+12016661234",
        "type" => "sms",
        "body" => "Second message",
        "timestamp" => "2024-11-01T14:05:00Z"
      })

    :ok
  end

  describe "GET /api/conversations" do
    test "lists all conversations", %{conn: conn} do
      conn = get(conn, ~p"/api/conversations")

      assert [conversation | _] = json_response(conn, 200)

      assert %{
               "id" => _id,
               "participants_key" => _key,
               "participants" => participants,
               "messages" => messages
             } = conversation

      assert is_list(participants)
      assert is_list(messages)
    end
  end

  describe "GET /api/conversations/:id/messages" do
    test "gets messages for a specific conversation", %{conn: conn} do
      # Get the conversation ID from the first conversation
      conn_list = get(conn, ~p"/api/conversations")
      [conversation | _] = json_response(conn_list, 200)
      conversation_id = conversation["id"]

      # Get messages for this conversation
      conn = get(conn, ~p"/api/conversations/#{conversation_id}/messages")

      assert messages = json_response(conn, 200)
      assert is_list(messages)
      assert length(messages) > 0

      # Verify message structure
      assert [first_message | _] = messages

      assert %{
               "id" => _id,
               "conversation_id" => ^conversation_id,
               "from" => _from,
               "to" => _to,
               "type" => _type,
               "direction" => _direction
             } = first_message
    end
  end
end
