defmodule MessagingServiceWeb.WebhookController do
  use MessagingServiceWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias MessagingService.Messaging

  alias MessagingServiceWeb.Schemas.{
    SmsWebhookRequest,
    EmailWebhookRequest,
    MessageResponse,
    ErrorResponse
  }

  action_fallback MessagingServiceWeb.FallbackController

  tags ["Webhooks"]

  operation :receive_sms,
    summary: "Receive SMS/MMS webhook",
    parameters: [],
    request_body: {"Webhook payload", "application/json", SmsWebhookRequest, required: true},
    responses: [
      ok: {"Webhook received", "application/json", MessageResponse},
      unprocessable_entity: {"Validation error", "application/json", ErrorResponse}
    ]

  def receive_sms(conn, params) do
    case Messaging.receive_message(params) do
      {:ok, message} ->
        conn
        |> put_status(:ok)
        |> json(render_message(message))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Validation error", details: format_changeset_errors(changeset)})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "An error occurred: #{inspect(reason)}"})
    end
  end

  operation :receive_email,
    summary: "Receive email webhook",
    parameters: [],
    request_body: {"Webhook payload", "application/json", EmailWebhookRequest, required: true},
    responses: [
      ok: {"Webhook received", "application/json", MessageResponse},
      unprocessable_entity: {"Validation error", "application/json", ErrorResponse}
    ]

  def receive_email(conn, params) do
    # Add type field for email if not present
    params_with_type = Map.put(params, :type, :email)

    case Messaging.receive_message(params_with_type) do
      {:ok, message} ->
        conn
        |> put_status(:ok)
        |> json(render_message(message))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Validation error", details: format_changeset_errors(changeset)})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "An error occurred: #{inspect(reason)}"})
    end
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

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
