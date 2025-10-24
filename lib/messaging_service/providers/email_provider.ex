defmodule MessagingService.Providers.EmailProvider do
  @moduledoc """
  Mock Email provider client using Tesla.
  In a real implementation, this would integrate with SendGrid or similar.
  """

  use MessagingService.Providers.BaseProvider

  @impl true
  def base_url, do: "https://api.mockemailprovider.com"

  @impl true
  def provider_id_prefix, do: "email_"
end
