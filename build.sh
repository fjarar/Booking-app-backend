#!/usr/bin/env bash
# Exit on any error
set -o errexit

# Check if running on Render
if [ "$RENDER" = "True" ]; then
  echo "🛠️ Running in production mode (Render)"
else
  echo "🔧 Running in development mode"
fi

# Install Python dependencies
pip install -r requirements.txt

# Collect static files (only in production)
if [ "$DEBUG" = "False" ]; then
  python manage.py collectstatic --noinput
fi

# Apply database migrations
python manage.py migrate