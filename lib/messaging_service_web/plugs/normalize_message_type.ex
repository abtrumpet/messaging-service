defmodule MessagingServiceWeb.Plugs.NormalizeMessageType do
  @moduledoc """
  Normalizes the 'type' parameter from string to atom for message type fields.
  This ensures consistent type handling throughout the application.
  """

  import Plug.Conn

  @message_types ["sms", "mms", "email"]

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.params do
      %{type: type} when is_binary(type) and type in @message_types ->
        normalized_params = Map.put(conn.params, :type, String.to_existing_atom(type))
        %{conn | params: normalized_params}

      _ ->
        conn
    end
  end
end
