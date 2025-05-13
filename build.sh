#!/usr/bin/env bash
set -o errexit

echo "➡️ Starting deployment..."

# 1. Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

# 2. Apply database migrations
echo "💾 Running migrations..."
python manage.py migrate --noinput

# 3. Create superuser (fixed indentation and error handling)
echo "👑 Creating superuser if needed..."
python manage.py shell <<EOF
import os
from django.contrib.auth import get_user_model
username = os.environ.get('DJANGO_SUPERUSER_USERNAME', 'admin')
email = os.environ.get('DJANGO_SUPERUSER_EMAIL', 'admin@example.com')
password = os.environ.get('DJANGO_SUPERUSER_PASSWORD', 'defaultpassword')

try:
    if not password or password == 'defaultpassword':
      print("❌ No password set in DJANGO_SUPERUSER_PASSWORD")
    else:
      User = get_user_model()
      if not User.objects.filter(username=username).exists():
          User.objects.create_superuser(username, email, password)
          print(f"✅ Superuser {username} created")
      else:
          print(f"ℹ️ Superuser {username} already exists")
except Exception as e:
    print(f'❌ Superuser creation failed: {e}')
EOF

# 4. Collect static files
echo "🖼️ Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "🚀 Deployment completed!"
