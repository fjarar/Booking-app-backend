#!/usr/bin/env bash
# Exit on any error
set -o errexit

# Check if running on Render
if [ "$RENDER" = "True" ]; then
  echo "🛠️ Running in production mode (Render)"
  
  # Install Python dependencies
  pip install -r requirements.txt

  # Collect static files
  python manage.py collectstatic --noinput

  # Apply database migrations
  python manage.py migrate

  # Create superuser only in production if none exists
  echo "
  from django.contrib.auth import get_user_model;
  User = get_user_model();
  if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
      User.objects.create_superuser(
          '$DJANGO_SUPERUSER_USERNAME',
          '$DJANGO_SUPERUSER_EMAIL',
          '$DJANGO_SUPERUSER_PASSWORD'
      )
      print('Superuser created successfully')
  else:
      print('Superuser already exists')
  " | python manage.py shell

else
  echo "🔧 Running in development mode"
  pip install -r requirements.txt
  python manage.py migrate
fi
