# BetterParams Integration Notes

## How BetterParams Works

BetterParams automatically converts string parameter keys to atoms using `String.to_existing_atom/1`. This is important for security - it only converts strings to atoms that already exist in the VM, preventing atom exhaustion attacks.

### Key Point: Atoms Must Exist First

`String.to_existing_atom/1` **only works if the atom already exists**. If you try to convert a string to an atom that doesn't exist, it will raise an `ArgumentError`.

## Our Implementation

### 1. BetterParams Plug (Endpoint Level)

In [lib/messaging_service_web/endpoint.ex](../lib/messaging_service_web/endpoint.ex):
```elixir
plug BetterParams
```

This converts all incoming parameter keys from strings to atoms (if the atom exists).

### 2. Type Normalization Plug (Route Level)

In [lib/messaging_service_web/plugs/normalize_message_type.ex](../lib/messaging_service_web/plugs/normalize_message_type.ex):
```elixir
@message_types ["sms", "mms", "email"]

def call(conn, _opts) do
  case conn.params do
    %{type: type} when is_binary(type) and type in @message_types ->
      normalized_params = Map.put(conn.params, :type, String.to_existing_atom(type))
      %{conn | params: normalized_params}
    _ ->
      conn
  end
end
```

This converts the `type` **value** from string to atom (e.g., `"sms"` → `:sms`).

### 3. Ensuring Webhook Atoms Exist

In [lib/messaging_service/messaging.ex](../lib/messaging_service/messaging.ex):
```elixir
# Ensure these atoms exist for BetterParams to work with webhook fields
@provider_id_fields [:messaging_provider_id, :xillio_id]
```

By referencing these atoms in a module attribute, we ensure they exist at compile time. This allows BetterParams to convert:
- `"messaging_provider_id"` → `:messaging_provider_id`
- `"xillio_id"` → `:xillio_id`

## Request Flow

### Example: SMS Webhook

1. **HTTP Request** arrives with:
   ```json
   {
     "from": "+18045551234",
     "to": "+12016661234",
     "type": "sms",
     "messaging_provider_id": "message-1",
     "body": "Hello",
     "timestamp": "2024-11-01T14:00:00Z"
   }
   ```

2. **BetterParams Plug** converts keys:
   ```elixir
   %{
     from: "+18045551234",
     to: "+12016661234",
     type: "sms",  # Still a string!
     messaging_provider_id: "message-1",
     body: "Hello",
     timestamp: "2024-11-01T14:00:00Z"
   }
   ```

3. **NormalizeMessageType Plug** converts type value:
   ```elixir
   %{
     from: "+18045551234",
     to: "+12016661234",
     type: :sms,  # Now an atom!
     messaging_provider_id: "message-1",
     body: "Hello",
     timestamp: "2024-11-01T14:00:00Z"
   }
   ```

4. **Controller** receives clean, atom-keyed params

5. **Context** works with atoms throughout:
   ```elixir
   def receive_message(attrs) do
     provider_id = attrs[:messaging_provider_id]  # Works because atom exists!
     # ...
   end
   ```

## Benefits

1. **Type Safety**: All internal code works with atoms, not strings
2. **Security**: Protected against atom exhaustion attacks
3. **Clean Code**: No string/atom mixing or manual conversion
4. **Consistent**: Same pattern throughout the application

## Gotchas

### 1. Path Parameters Are NOT Converted

**Important**: BetterParams does **not** convert `path_params` (yet). This is on their roadmap but not implemented.

Example:
```elixir
# Route: GET /api/conversations/:id/messages
# URL: /api/conversations/123/messages

# In controller:
def messages(conn, %{"id" => id}) do  # ✓ "id" is still a STRING key
  conversation_id = String.to_integer(id)  # Must manually convert to integer
  # ...
end

# This WON'T work:
def messages(conn, %{id: id}) do  # ✗ Pattern match fails!
```

**Why?** BetterParams only converts the `params` map (query params and body params), not `path_params`.

### 2. New Webhook Fields Need Atom Definitions

If you add new webhook fields in the future:
1. Define them as atoms somewhere (module attribute, function head, etc.)
2. Or use string access: `attrs["new_field"]` (but this breaks consistency)

Example:
```elixir
# If adding a new field called "external_id":
@webhook_fields [:messaging_provider_id, :xillio_id, :external_id]

# Now BetterParams can convert "external_id" → :external_id
```
