defmodule MessagingServiceWeb.Schemas do
  @moduledoc """
  OpenAPI schema definitions for the Messaging Service API.
  """

  alias OpenApiSpex.Schema

  defmodule SmsMessageRequest do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "SmsMessageRequest",
      description: "Request body for sending SMS/MMS messages",
      type: :object,
      properties: %{
        from: %Schema{type: :string, description: "Sender phone number"},
        to: %Schema{type: :string, description: "Recipient phone number"},
        type: %Schema{type: :string, enum: ["sms", "mms"], description: "Message type"},
        body: %Schema{type: :string, description: "Message content"},
        attachments: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Array of attachment URLs",
          nullable: true
        },
        timestamp: %Schema{type: :string, format: :"date-time", description: "Message timestamp"}
      },
      required: [:from, :to, :type, :timestamp],
      example: %{
        from: "+12016661234",
        to: "+18045551234",
        type: "sms",
        body: "Hello! This is a test SMS message.",
        attachments: nil,
        timestamp: "2024-11-01T14:00:00Z"
      }
    })
  end

  defmodule EmailMessageRequest do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "EmailMessageRequest",
      description: "Request body for sending email messages",
      type: :object,
      properties: %{
        from: %Schema{type: :string, format: :email, description: "Sender email address"},
        to: %Schema{type: :string, format: :email, description: "Recipient email address"},
        body: %Schema{type: :string, description: "Message content (HTML allowed)"},
        attachments: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Array of attachment URLs"
        },
        timestamp: %Schema{type: :string, format: :"date-time", description: "Message timestamp"}
      },
      required: [:from, :to, :timestamp],
      example: %{
        from: "user@usehatchapp.com",
        to: "contact@gmail.com",
        body: "Hello! This is a test email message with <b>HTML</b> formatting.",
        attachments: ["https://example.com/document.pdf"],
        timestamp: "2024-11-01T14:00:00Z"
      }
    })
  end

  defmodule SmsWebhookRequest do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "SmsWebhookRequest",
      description: "Webhook payload for incoming SMS/MMS messages",
      type: :object,
      properties: %{
        from: %Schema{type: :string, description: "Sender phone number"},
        to: %Schema{type: :string, description: "Recipient phone number"},
        type: %Schema{type: :string, enum: ["sms", "mms"], description: "Message type"},
        messaging_provider_id: %Schema{type: :string, description: "SMS provider's message ID"},
        body: %Schema{type: :string, description: "Message content"},
        attachments: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Array of attachment URLs",
          nullable: true
        },
        timestamp: %Schema{type: :string, format: :"date-time", description: "Message timestamp"}
      },
      required: [:from, :to, :type, :messaging_provider_id, :timestamp],
      example: %{
        from: "+18045551234",
        to: "+12016661234",
        type: "sms",
        messaging_provider_id: "message-1",
        body: "This is an incoming SMS message",
        attachments: nil,
        timestamp: "2024-11-01T14:00:00Z"
      }
    })
  end

  defmodule EmailWebhookRequest do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "EmailWebhookRequest",
      description: "Webhook payload for incoming email messages",
      type: :object,
      properties: %{
        from: %Schema{type: :string, format: :email, description: "Sender email address"},
        to: %Schema{type: :string, format: :email, description: "Recipient email address"},
        xillio_id: %Schema{type: :string, description: "Email provider's message ID"},
        body: %Schema{type: :string, description: "Message content (HTML allowed)"},
        attachments: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Array of attachment URLs"
        },
        timestamp: %Schema{type: :string, format: :"date-time", description: "Message timestamp"}
      },
      required: [:from, :to, :xillio_id, :timestamp],
      example: %{
        from: "contact@gmail.com",
        to: "user@usehatchapp.com",
        xillio_id: "message-3",
        body: "<html><body>This is an incoming email with <b>HTML</b> content</body></html>",
        attachments: ["https://example.com/received-document.pdf"],
        timestamp: "2024-11-01T14:00:00Z"
      }
    })
  end

  defmodule MessageResponse do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "MessageResponse",
      description: "Response for message operations",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Message ID"},
        conversation_id: %Schema{type: :integer, description: "Conversation ID"},
        from: %Schema{type: :string, description: "Sender"},
        to: %Schema{type: :string, description: "Recipient"},
        type: %Schema{type: :string, description: "Message type"},
        body: %Schema{type: :string, description: "Message content", nullable: true},
        attachments: %Schema{type: :array, items: %Schema{type: :string}, nullable: true},
        provider_id: %Schema{type: :string, description: "Provider message ID", nullable: true},
        direction: %Schema{type: :string, enum: ["inbound", "outbound"]},
        message_timestamp: %Schema{type: :string, format: :"date-time"},
        inserted_at: %Schema{type: :string, format: :"date-time"},
        updated_at: %Schema{type: :string, format: :"date-time"}
      }
    })
  end

  defmodule ConversationResponse do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ConversationResponse",
      description: "Response for conversation operations",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Conversation ID"},
        participants_key: %Schema{type: :string, description: "Normalized participants key"},
        participants: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "List of participants"
        },
        messages: %Schema{
          type: :array,
          items: MessageResponse,
          description: "Messages in the conversation"
        },
        inserted_at: %Schema{type: :string, format: :"date-time"},
        updated_at: %Schema{type: :string, format: :"date-time"}
      }
    })
  end

  defmodule ErrorResponse do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ErrorResponse",
      description: "Error response",
      type: :object,
      properties: %{
        error: %Schema{type: :string, description: "Error message"}
      },
      example: %{error: "Invalid request"}
    })
  end
end
