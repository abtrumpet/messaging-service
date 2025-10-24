#!/bin/bash

set -e

echo "Starting the Messaging Service application..."
echo "Environment: ${ENV:-development}"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL..."
until PGPASSWORD=messaging_password psql -h localhost -U messaging_user -d messaging_service -c '\q' 2>/dev/null; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

echo "PostgreSQL is up - continuing..."

# Install dependencies if needed
if [ ! -d "deps" ]; then
  echo "Installing dependencies..."
  mix deps.get
fi

# Create and migrate database
echo "Setting up database..."
mix ecto.create 2>/dev/null || echo "Database already exists"
mix ecto.migrate

# Start the Phoenix server
echo "Starting Phoenix server on port 8080..."
mix phx.server 