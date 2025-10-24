defmodule MessagingServiceWeb.Plugs.NormalizeMessageType do
  @moduledoc """
  Normalizes the 'type' parameter from string to atom for message type fields.
  This ensures consistent type handling throughout the application.
  """

  @message_types [:sms, :mms, :email]

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.params do
      %{type: type} when is_binary(type) ->
        # Convert type string to atom if it's a valid message type
        type_atom = String.to_existing_atom(type)

        if type_atom in @message_types do
          normalized_params = Map.put(conn.params, :type, type_atom)
          %{conn | params: normalized_params}
        else
          conn
        end

      _ ->
        conn
    end
  rescue
    ArgumentError ->
      # If the atom doesn't exist, just return conn unchanged
      conn
  end
end
