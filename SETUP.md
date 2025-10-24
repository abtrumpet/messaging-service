# Messaging Service - Setup Guide

This Phoenix application implements a unified messaging API supporting SMS, MMS, and Email providers with the following technology stack:

## Tech Stack

- **Elixir 1.19.1** / **Erlang/OTP 28**
- **Phoenix 1.8.1** - Web framework (API-only, no LiveView)
- **Ecto 3.13** + **Postgrex 0.21** - Database layer
- **Tesla 1.15** - HTTP client for provider integrations
- **OpenApiSpex 3.22** - OpenAPI specification generation
- **Hammox 0.7** - Mocking library for tests
- **BetterParams 0.5** - Parameter normalization (string keys → atoms)

## Architecture

### Database Schema

- **conversations** - Groups messages by participants
  - `participants_key`: Normalized key for deduplication
  - `participants`: Array of participant identifiers

- **messages** - All sent/received messages
  - Links to conversation
  - Stores provider info, direction (inbound/outbound)
  - Indexed on from/to/timestamp for performance

### Key Features

1. **Unified API** - Single interface for SMS/MMS/Email
2. **Automatic Conversation Grouping** - Messages grouped by participants
3. **Provider Abstraction** - Tesla-based clients with behaviour for mockability
4. **OpenAPI Documentation** - Full spec + Swagger UI at `/api/swagger`
5. **Error Handling** - Graceful handling of provider errors (429, 500, 404, 401)

## Getting Started

### Prerequisites

- Elixir 1.19+ and Erlang/OTP 28+
- Docker and Docker Compose (for PostgreSQL)
- PostgreSQL client tools (psql)

### Installation

1. **Start the database**:
   ```bash
   make setup
   # or
   docker-compose up -d
   ```

2. **Install dependencies**:
   ```bash
   mix deps.get
   ```

3. **Create and migrate database**:
   ```bash
   mix ecto.setup
   ```

4. **Start the server**:
   ```bash
   make run
   # or
   ./bin/start.sh
   ```

The application will start on `http://localhost:8080`

### Running Tests

```bash
make test
# or
mix test
```

## API Endpoints

### Send Messages
- `POST /api/messages/sms` - Send SMS/MMS
- `POST /api/messages/email` - Send Email

### Receive Webhooks
- `POST /api/webhooks/sms` - Receive SMS/MMS
- `POST /api/webhooks/email` - Receive Email

### Conversations
- `GET /api/conversations` - List all conversations
- `GET /api/conversations/:id/messages` - Get messages for conversation

### Documentation
- `GET /api/openapi` - OpenAPI JSON spec
- `GET /api/swagger` - Swagger UI interface

## Provider Error Simulation

The mock providers support error simulation via recipient addresses:

- **429 errors**: Send to number/email containing "429"
- **500 errors**: Send to number/email containing "500"
- **404 errors**: Send to number/email containing "404"
- **401 errors**: Send to number/email containing "401"

Example:
```json
{
  "from": "+12016661234",
  "to": "+1804555429",
  "type": "sms",
  "body": "This will trigger rate limiting",
  "timestamp": "2024-11-01T14:00:00Z"
}
```

## Project Structure

```
lib/
├── messaging_service/           # Business logic
│   ├── application.ex          # OTP application
│   ├── repo.ex                 # Ecto repository
│   ├── conversation.ex         # Conversation schema
│   ├── message.ex              # Message schema
│   ├── messaging.ex            # Messaging context
│   └── providers/              # Provider clients
│       ├── behaviour.ex        # Provider behaviour
│       ├── sms_provider.ex     # SMS/MMS Tesla client
│       └── email_provider.ex   # Email Tesla client
└── messaging_service_web/       # Web layer
    ├── endpoint.ex             # Phoenix endpoint
    ├── router.ex               # Route definitions
    ├── api_spec.ex             # OpenAPI spec
    ├── schemas.ex              # OpenAPI schemas
    ├── telemetry.ex            # Metrics
    └── controllers/            # Controllers
        ├── message_controller.ex
        ├── webhook_controller.ex
        ├── conversation_controller.ex
        ├── fallback_controller.ex
        └── error_json.ex

test/
├── messaging_service_web/
│   └── controllers/            # Integration tests
└── support/                    # Test helpers
```

## Configuration

### Database (docker-compose.yml)
- **Host**: localhost:5432
- **Database**: messaging_service
- **User**: messaging_user
- **Password**: messaging_password

### Environment Variables
- `PORT`: Server port (default: 8080)
- `DATABASE_URL`: PostgreSQL connection string (optional)
- `MIX_ENV`: Environment (dev/test/prod)

## Development Notes

### Parameter Handling

The application uses `BetterParams` plug to automatically convert string parameter keys to atoms. This means all context functions and internal logic work with atom keys, making the code cleaner and type-safe.

### Provider Mocking with Hammox

Providers implement a behaviour that can be mocked in tests using Hammox. See `test/support/` for test configuration.

### Conversation Grouping

Messages are automatically grouped into conversations based on normalized participant identifiers (case-insensitive, sorted). The same conversation is used regardless of message direction.

## Troubleshooting

### Database Connection Issues
```bash
# Check if PostgreSQL is running
docker-compose ps

# View database logs
docker-compose logs postgres

# Connect to database manually
docker-compose exec postgres psql -U messaging_user -d messaging_service
```

### Dependency Issues
```bash
# Clean and reinstall
mix deps.clean --all
mix deps.get
mix deps.compile
```

### Port Already in Use
```bash
# Check what's using port 8080
lsof -i :8080

# Or change the port in config/dev.exs
```

## Next Steps

1. Review the OpenAPI spec at `http://localhost:8080/api/swagger`
2. Run the test script: `./bin/test.sh`
3. Check test coverage: `mix test --cover`
4. Review provider implementations for real integration
