defmodule MessagingServiceWeb.WebhookControllerTest do
  use MessagingServiceWeb.ConnCase

  describe "POST /api/webhooks/sms" do
    test "successfully receives an SMS webhook", %{conn: conn} do
      params = %{
        "from" => "+18045551234",
        "to" => "+12016661234",
        "type" => "sms",
        "messaging_provider_id" => "message-1",
        "body" => "Incoming SMS message",
        "attachments" => nil,
        "timestamp" => "2024-11-01T14:00:00Z"
      }

      conn = post(conn, ~p"/api/webhooks/sms", params)

      assert %{
               "from" => "+18045551234",
               "to" => "+12016661234",
               "type" => "sms",
               "body" => "Incoming SMS message",
               "provider_id" => "message-1",
               "direction" => "inbound"
             } = json_response(conn, 200)
    end

    test "successfully receives an MMS webhook", %{conn: conn} do
      params = %{
        "from" => "+18045551234",
        "to" => "+12016661234",
        "type" => "mms",
        "messaging_provider_id" => "message-2",
        "body" => "Incoming MMS message",
        "attachments" => ["https://example.com/received-image.jpg"],
        "timestamp" => "2024-11-01T14:00:00Z"
      }

      conn = post(conn, ~p"/api/webhooks/sms", params)

      assert %{
               "type" => "mms",
               "attachments" => ["https://example.com/received-image.jpg"]
             } = json_response(conn, 200)
    end
  end

  describe "POST /api/webhooks/email" do
    test "successfully receives an email webhook", %{conn: conn} do
      params = %{
        "from" => "contact@gmail.com",
        "to" => "user@usehatchapp.com",
        "xillio_id" => "message-3",
        "body" => "<html><body>Incoming email with <b>HTML</b></body></html>",
        "attachments" => ["https://example.com/received-document.pdf"],
        "timestamp" => "2024-11-01T14:00:00Z"
      }

      conn = post(conn, ~p"/api/webhooks/email", params)

      assert %{
               "from" => "contact@gmail.com",
               "to" => "user@usehatchapp.com",
               "type" => "email",
               "provider_id" => "message-3",
               "direction" => "inbound"
             } = json_response(conn, 200)
    end
  end
end
