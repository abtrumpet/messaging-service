defmodule MessagingService.Providers.Behaviour do
  @moduledoc """
  Behaviour for messaging provider clients.
  This allows us to mock providers in tests using Hammox.
  """

  @callback send_message(map()) :: {:ok, map()} | {:error, term()}
end
