defmodule MessagingServiceWeb.Router do
  use MessagingServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: MessagingServiceWeb.ApiSpec
  end

  pipeline :normalize_message_type do
    plug MessagingServiceWeb.Plugs.NormalizeMessageType
  end

  scope "/api" do
    pipe_through :api

    # OpenAPI spec endpoints
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    get "/swagger", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"

    # Message sending endpoints (normalize type param)
    scope "/messages" do
      pipe_through :normalize_message_type

      post "/sms", MessagingServiceWeb.MessageController, :send_sms
      post "/email", MessagingServiceWeb.MessageController, :send_email
    end

    # Webhook endpoints (normalize type param)
    scope "/webhooks" do
      pipe_through :normalize_message_type

      post "/sms", MessagingServiceWeb.WebhookController, :receive_sms
      post "/email", MessagingServiceWeb.WebhookController, :receive_email
    end

    # Conversation endpoints
    get "/conversations", MessagingServiceWeb.ConversationController, :index
    get "/conversations/:id/messages", MessagingServiceWeb.ConversationController, :messages
  end
end
