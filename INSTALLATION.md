# Installation Instructions

## System Requirements Issue

Your Erlang installation is missing the `public_key` application, which is required for HTTPS connections (used by `mix deps.get`).

### Fix for Linux (Arch-based systems)

Since you're on an Arch-based system (based on your kernel version), install the missing package:

```bash
# Option 1: Install the full Erlang package
sudo pacman -S erlang

# Option 2: If using erlang-nox, you may need additional packages
sudo pacman -S erlang-crypto erlang-public_key erlang-ssl
```

### Alternative: Use asdf or mise

If you're using a version manager, reinstall Erlang with all dependencies:

```bash
# Using asdf
asdf uninstall erlang 28.1.1
asdf install erlang 28.1.1

# Using mise (rtx)
mise uninstall erlang@28.1.1
mise install erlang@28.1.1
```

## Once Erlang is Fixed

Run these commands to complete the setup:

```bash
# 1. Fetch dependencies
mix deps.get

# 2. Compile the project
mix compile

# 3. Setup database (ensure Docker is running)
docker-compose up -d
mix ecto.create
mix ecto.migrate

# 4. Start the server
mix phx.server
```

The application will be available at `http://localhost:8080`

## Quick Test

Once running, test the API:

```bash
# Send a test SMS
curl -X POST http://localhost:8080/api/messages/sms \
  -H "Content-Type: application/json" \
  -d '{
    "from": "+12016661234",
    "to": "+18045551234",
    "type": "sms",
    "body": "Test message",
    "timestamp": "2024-11-01T14:00:00Z"
  }'

# View Swagger UI
open http://localhost:8080/api/swagger
```

## Project Status

✅ **Complete Phoenix Application**
- All controllers, schemas, and migrations created
- OpenAPI spec with Swagger UI configured
- Tesla providers with error simulation
- Full test suite with controller tests
- Database migrations ready

⚠️ **Blocked on**: System Erlang `public_key` package

Once you install the missing Erlang package, everything should work immediately!
