defmodule MessagingService.Providers.SmsProvider do
  @moduledoc """
  Mock SMS/MMS provider client using Tesla.
  In a real implementation, this would integrate with Twilio or similar.
  """

  @behaviour MessagingService.Providers.Behaviour

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.mocksmsprovider.com"
  plug Tesla.Middleware.JSON, engine: Jason
  plug Tesla.Middleware.Headers, [{"content-type", "application/json"}]

  @impl true
  def send_message(params) do
    # Simulate API call with mock success/error responses
    case simulate_send(params) do
      {:ok, _response} ->
        provider_id = "msg_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"
        {:ok, %{provider_id: provider_id, status: "sent"}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Simulate different provider responses for testing
  defp simulate_send(params) do
    to = params[:to] || ""

    cond do
      # Simulate rate limiting
      String.contains?(to, "429") ->
        {:error, :rate_limited}

      # Simulate server error
      String.contains?(to, "500") ->
        {:error, :server_error}

      # Simulate not found
      String.contains?(to, "404") ->
        {:error, :not_found}

      # Simulate unauthorized
      String.contains?(to, "401") ->
        {:error, :unauthorized}

      # Default success
      true ->
        {:ok, %{success: true}}
    end
  end
end
