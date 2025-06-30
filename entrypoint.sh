#!/bin/bash
set -e

# Remove any existing server PID file to prevent conflicts
rm -f /app/tmp/pids/server.pid

exec "$@"