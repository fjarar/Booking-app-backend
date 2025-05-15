from django.core.files.storage import Storage
from django.utils.deconstruct import deconstructible
from django.utils.text import get_valid_filename
from supabase import create_client
from django.conf import settings
import os

@deconstructible
class SupabaseStorage(Storage):
    def __init__(self):
        self.client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
        self.bucket = settings.SUPABASE_BUCKET_NAME

    def _save(self, name, content):
        name = self.get_valid_name(name)
        content.seek(0)
        self.client.storage.from_(self.bucket).upload(
            path=name,
            file=content.read(),
            file_options={"content-type": content.content_type}
        )
        return name

    def exists(self, name):
        """Check if file exists in Supabase"""
        try:
            res = self.client.storage.from_(self.bucket).list(path=os.path.dirname(name))
            return any(file['name'] == os.path.basename(name) for file in res)
        except Exception:
            return False

    def url(self, name):
        return f"{settings.SUPABASE_URL}/storage/v1/object/public/{self.bucket}/{name}"

    # Required Django methods
    def get_valid_name(self, name):
        return get_valid_filename(name)

    def generate_filename(self, filename):
        return filename

    def path(self, name):
        raise NotImplementedError("Supabase storage doesn't support local paths")

    def delete(self, name):
        self.client.storage.from_(self.bucket).remove([name])

    def size(self, name):
        try:
            res = self.client.storage.from_(self.bucket).list(path=os.path.dirname(name))
            file = next(f for f in res if f['name'] == os.path.basename(name))
            return file['metadata']['size']
        except Exception:
            return 0