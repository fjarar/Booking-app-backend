#!/usr/bin/env bash
# Exit on any error
set -o errexit

# Check if running on Render
if [ "$RENDER" = "True" ]; then
  echo "🛠️ Running in production mode (Render)"
  
  # 1. Install dependencies (including WhiteNoise)
  pip install -r requirements.txt

  # 2. Force clean static files collection (critical fix)
  echo "🧹 Clearing old static files..."
  rm -rf staticfiles/ || true

  # 3. Collect static with verbose output
  echo "📦 Collecting static files..."
  python manage.py collectstatic --noinput --clear 2>&1 | while read line; do echo "    $line"; done

  # 4. Apply migrations
  echo "💾 Running migrations..."
  python manage.py migrate

  # 5. Safe superuser creation (with error handling)
  echo "👑 Creating superuser if needed..."
  echo "
  import os
  from django.contrib.auth import get_user_model
  try:
      User = get_user_model()
      if not User.objects.filter(username=os.environ['DJANGO_SUPERUSER_USERNAME']).exists():
          User.objects.create_superuser(
              os.environ['DJANGO_SUPERUSER_USERNAME'],
              os.environ['DJANGO_SUPERUSER_EMAIL'],
              os.environ['DJANGO_SUPERUSER_PASSWORD']
          )
          print('Superuser created successfully')
      else:
          print('Superuser already exists')
  except Exception as e:
      print(f'Superuser creation error: {e}')
  " | python manage.py shell

else
  echo "🔧 Running in development mode"
  pip install -r requirements.txt
  python manage.py migrate
fi

echo "✅ Build completed successfully!"
