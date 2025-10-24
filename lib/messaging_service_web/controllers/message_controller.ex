defmodule MessagingServiceWeb.MessageController do
  use MessagingServiceWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias MessagingService.Messaging

  alias MessagingServiceWeb.Schemas.{
    SmsMessageRequest,
    EmailMessageRequest,
    MessageResponse,
    ErrorResponse
  }

  action_fallback MessagingServiceWeb.FallbackController

  tags ["Messages"]

  operation :send_sms,
    summary: "Send SMS/MMS message",
    parameters: [],
    request_body: {"Message parameters", "application/json", SmsMessageRequest, required: true},
    responses: [
      ok: {"Message sent", "application/json", MessageResponse},
      unprocessable_entity: {"Validation error", "application/json", ErrorResponse},
      too_many_requests: {"Rate limited", "application/json", ErrorResponse},
      internal_server_error: {"Server error", "application/json", ErrorResponse}
    ]

  def send_sms(conn, params) do
    case Messaging.send_message(params) do
      {:ok, message} ->
        conn
        |> put_status(:ok)
        |> json(render_message(message))

      {:error, :rate_limited} ->
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: "Rate limited"})

      {:error, :server_error} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Provider server error"})

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

  operation :send_email,
    summary: "Send email message",
    parameters: [],
    request_body: {"Message parameters", "application/json", EmailMessageRequest, required: true},
    responses: [
      ok: {"Message sent", "application/json", MessageResponse},
      unprocessable_entity: {"Validation error", "application/json", ErrorResponse},
      too_many_requests: {"Rate limited", "application/json", ErrorResponse},
      internal_server_error: {"Server error", "application/json", ErrorResponse}
    ]

  def send_email(conn, params) do
    # Add type field for email if not present
    params_with_type = Map.put(params, :type, :email)

    case Messaging.send_message(params_with_type) do
      {:ok, message} ->
        conn
        |> put_status(:ok)
        |> json(render_message(message))

      {:error, :rate_limited} ->
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: "Rate limited"})

      {:error, :server_error} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Provider server error"})

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
