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

try:
    User = get_user_model()
    if not User.objects.filter(username=os.environ.get('DJANGO_SUPERUSER_USERNAME')).exists():
        User.objects.create_superuser(
            os.environ.get('DJANGO_SUPERUSER_USERNAME'),
            os.environ.get('DJANGO_SUPERUSER_EMAIL'),
            os.environ.get('DJANGO_SUPERUSER_PASSWORD')
        )
        print('✅ Superuser created successfully')
    else:
        print('ℹ️ Superuser already exists')
except Exception as e:
    print(f'❌ Superuser creation failed: {e}')
EOF

# 4. Collect static files
echo "🖼️ Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "🚀 Deployment completed!"
