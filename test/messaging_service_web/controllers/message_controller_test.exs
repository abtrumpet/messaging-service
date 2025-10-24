defmodule MessagingServiceWeb.MessageControllerTest do
  use MessagingServiceWeb.ConnCase

  describe "POST /api/messages/sms" do
    test "successfully sends an SMS message", %{conn: conn} do
      params = %{
        "from" => "+12016661234",
        "to" => "+18045551234",
        "type" => "sms",
        "body" => "Test SMS message",
        "attachments" => nil,
        "timestamp" => "2024-11-01T14:00:00Z"
      }

      conn = post(conn, ~p"/api/messages/sms", params)

      assert %{
               "id" => _id,
               "from" => "+12016661234",
               "to" => "+18045551234",
               "type" => "sms",
               "body" => "Test SMS message",
               "direction" => "outbound",
               "provider_id" => provider_id
             } = json_response(conn, 200)

      assert is_binary(provider_id)
    end

    test "successfully sends an MMS message with attachments", %{conn: conn} do
      params = %{
        "from" => "+12016661234",
        "to" => "+18045551234",
        "type" => "mms",
        "body" => "Test MMS message",
        "attachments" => ["https://example.com/image.jpg"],
        "timestamp" => "2024-11-01T14:00:00Z"
      }

      conn = post(conn, ~p"/api/messages/sms", params)

      assert %{
               "type" => "mms",
               "attachments" => ["https://example.com/image.jpg"]
             } = json_response(conn, 200)
    end

    test "returns 429 when rate limited", %{conn: conn} do
      params = %{
        "from" => "+12016661234",
        "to" => "+1804555429",
        "type" => "sms",
        "body" => "Test",
        "timestamp" => "2024-11-01T14:00:00Z"
      }

      conn = post(conn, ~p"/api/messages/sms", params)
      assert %{"error" => "Rate limited"} = json_response(conn, 429)
    end

    test "returns 500 when provider has server error", %{conn: conn} do
      params = %{
        "from" => "+12016661234",
        "to" => "+1804555500",
        "type" => "sms",
        "body" => "Test",
        "timestamp" => "2024-11-01T14:00:00Z"
      }

      conn = post(conn, ~p"/api/messages/sms", params)
      assert %{"error" => "Provider server error"} = json_response(conn, 500)
    end
  end

  describe "POST /api/messages/email" do
    test "successfully sends an email message", %{conn: conn} do
      params = %{
        "from" => "user@usehatchapp.com",
        "to" => "contact@gmail.com",
        "body" => "Test email with <b>HTML</b>",
        "attachments" => ["https://example.com/document.pdf"],
        "timestamp" => "2024-11-01T14:00:00Z"
      }

      conn = post(conn, ~p"/api/messages/email", params)

      assert %{
               "from" => "user@usehatchapp.com",
               "to" => "contact@gmail.com",
               "type" => "email",
               "body" => "Test email with <b>HTML</b>",
               "direction" => "outbound"
             } = json_response(conn, 200)
    end
  end
end
