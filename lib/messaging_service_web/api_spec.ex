defmodule MessagingServiceWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  alias MessagingServiceWeb.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "Messaging Service API",
        version: "1.0.0",
        description: """
        A unified messaging API that supports SMS, MMS, and Email providers.

        This service provides:
        - Send messages through various providers
        - Receive webhook messages
        - Manage conversations grouped by participants
        """
      },
      paths: Paths.from_router(Router)
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
