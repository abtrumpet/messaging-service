# Changelog

## [Unreleased]

### Added
- Complete Phoenix 1.8.1 API-only application
- Tesla 1.15.3 HTTP clients for SMS/MMS and Email providers
- OpenApiSpex 3.22.0 with Swagger UI at `/api/swagger`
- Hammox 0.7.1 for provider mocking in tests
- BetterParams 0.5.0 for automatic param key normalization
- Full test suite with controller integration tests
- Database migrations for conversations and messages
- Automatic conversation grouping by participants
- Provider error simulation (429, 500, 404, 401)

### Removed
- All LiveView traces:
  - Removed `socket "/live"` from endpoint
  - Removed `live_view` config from config.exs
  - Removed `Phoenix.LiveView.HTMLFormatter` from .formatter.exs
  - Removed `.heex` file patterns from formatter inputs
  - Removed Plug.Static (not needed for API-only app)

### Fixed
- Ecto preload query syntax in `Messaging.list_conversations/0`
- Ecto preload query syntax in `Messaging.get_conversation!/1`
- Added missing `telemetry_metrics` and `telemetry_poller` dependencies
- Added missing `finch` dependency for Application supervision tree

### Configuration
- Tesla adapter configured to use Hackney
- Jason configured as JSON library
- BetterParams plug added to endpoint for param normalization
- OpenAPI spec and Swagger UI routes configured

## Application Structure

This is a pure API application with:
- **No HTML/LiveView** - JSON API only
- **No static assets** - No asset pipeline needed
- **No sessions** - Stateless API design (though session config kept for potential future use)
- **No cookies** - API authentication would use tokens (not yet implemented)

The application provides:
1. RESTful JSON API for messaging operations
2. Webhook endpoints for receiving messages
3. OpenAPI 3.0 specification
4. Interactive Swagger UI documentation
5. Automatic conversation management
6. Provider abstraction layer with mock implementations
