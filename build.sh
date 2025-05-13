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
username = "admin"  # Hardcoded for testing
email = "admin@example.com"
password = "admin1234"  # Simple but valid password

User = get_user_model()
if User.objects.filter(username=username).exists():
    # Reset password if user exists
    user = User.objects.get(username=username)
    user.set_password(password)
    user.save()
    print(f"✓ Password reset for {username}")
else:
    User.objects.create_superuser(username, email, password)
    print(f"✓ Created superuser {username}")
EOF

# 4. Collect static files
echo "🖼️ Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "🚀 Deployment completed!"
