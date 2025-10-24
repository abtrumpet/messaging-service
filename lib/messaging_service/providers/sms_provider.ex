defmodule MessagingService.Providers.SmsProvider do
  @moduledoc """
  Mock SMS/MMS provider client using Tesla.
  In a real implementation, this would integrate with Twilio or similar.
  """

  use MessagingService.Providers.BaseProvider

  @impl true
  def base_url, do: "https://api.mocksmsprovider.com"

  @impl true
  def provider_id_prefix, do: "msg_"
end
