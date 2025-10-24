defmodule MessagingService.Providers.BaseProvider do
  @moduledoc """
  Base module for messaging providers with shared Tesla configuration
  and common mock simulation logic.

  To use this module, define a provider module that:
  1. `use MessagingService.Providers.BaseProvider`
  2. Implements the `base_url/0` callback to provide the API endpoint
  3. Implements the `provider_id_prefix/0` callback to customize generated IDs

  ## Example

      defmodule MyApp.Providers.SmsProvider do
        use MessagingService.Providers.BaseProvider

        @impl true
        def base_url, do: "https://api.mocksmsprovider.com"

        @impl true
        def provider_id_prefix, do: "msg_"
      end
  """

  @doc """
  Returns the base URL for the provider API.
  """
  @callback base_url() :: String.t()

  @doc """
  Returns the prefix to use when generating provider IDs.
  """
  @callback provider_id_prefix() :: String.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour MessagingService.Providers.Behaviour
      @behaviour MessagingService.Providers.BaseProvider

      use Tesla

      plug Tesla.Middleware.Finch, name: MessagingService.Finch
      plug Tesla.Middleware.BaseUrl, base_url()
      plug Tesla.Middleware.JSON, engine: Jason
      plug Tesla.Middleware.Headers, [{"content-type", "application/json"}]

      @impl MessagingService.Providers.Behaviour
      def send_message(params) do
        # Simulate API call with mock success/error responses
        case simulate_send(params) do
          {:ok, _response} ->
            provider_id = "#{provider_id_prefix()}#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"
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

      # Allow modules to override simulate_send if needed
      defoverridable simulate_send: 1
    end
  end
end
