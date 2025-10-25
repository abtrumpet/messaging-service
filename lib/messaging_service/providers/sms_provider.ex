defmodule MessagingService.Providers.SmsProvider do
  @moduledoc """
  Mock SMS/MMS provider client using Tesla.
  In a real implementation, this would integrate with Twilio or similar.

  Follows the canonical Tesla pattern with a `client/0` function that returns
  a configured client, and API functions that accept the client as a parameter.
  """

  @behaviour MessagingService.Providers.Behaviour

  @doc """
  Creates a configured Tesla client for the SMS provider.
  """
  def client do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.mocksmsprovider.com"},
      {Tesla.Middleware.JSON, engine: Jason},
      {Tesla.Middleware.Headers, [{"content-type", "application/json"}]},
      {Tesla.Middleware.Finch, name: MessagingService.Finch}
    ]

    Tesla.client(middleware)
  end

  @doc """
  Sends an SMS/MMS message via the provider API.

  In a real implementation, this would use:
  Tesla.post(client, "/messages", params)
  """
  @impl MessagingService.Providers.Behaviour
  def send_message(params) do
    # In a real implementation:
    # case Tesla.post(client(), "/messages", params) do
    #   {:ok, %Tesla.Env{status: 201, body: body}} ->
    #     {:ok, %{provider_id: body["sid"], status: body["status"]}}
    #   {:ok, %Tesla.Env{status: status}} ->
    #     {:error, {:http_error, status}}
    #   {:error, reason} ->
    #     {:error, reason}
    # end

    # Mock simulation for testing
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
    to = params["to"] || ""

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
