import urllib.request
import io
import os
import sys
import zipfile
import shutil

class BufferedRangeHTTPFile(io.RawIOBase):
    def __init__(self, url, length, chunk_size=8 * 1024 * 1024):
        self.url = url
        self.length = length
        self.chunk_size = chunk_size
        self.pos = 0
        self.buf = b''
        self.buf_start = 0

    def seekable(self):
        return True

    def readable(self):
        return True

    def seek(self, offset, whence=io.SEEK_SET):
        if whence == io.SEEK_SET:
            self.pos = offset
        elif whence == io.SEEK_CUR:
            self.pos += offset
        elif whence == io.SEEK_END:
            self.pos = self.length + offset
        return self.pos

    def tell(self):
        return self.pos

    def readinto(self, b):
        l = len(b)
        if self.pos >= self.length or l == 0:
            return 0

        # Check if requested range is in current buffer
        if not (self.buf_start <= self.pos < self.buf_start + len(self.buf)):
            # Fetch a new chunk
            fetch_size = max(l, self.chunk_size)
            end = min(self.pos + fetch_size - 1, self.length - 1)
            req = urllib.request.Request(
                self.url,
                headers={'Range': f'bytes={self.pos}-{end}', 'User-Agent': 'Mozilla/5.0'}
            )
            with urllib.request.urlopen(req) as resp:
                self.buf = resp.read()
                self.buf_start = self.pos

        offset_in_buf = self.pos - self.buf_start
        available = len(self.buf) - offset_in_buf
        to_copy = min(l, available)
        b[:to_copy] = self.buf[offset_in_buf:offset_in_buf + to_copy]
        self.pos += to_copy
        return to_copy

def setup_templates():
    appdata = os.environ.get('APPDATA')
    if not appdata:
        print("Error: APPDATA environment variable not set")
        return False
    
    target_dir = os.path.join(appdata, 'Godot', 'export_templates', '4.3.stable')
    os.makedirs(target_dir, exist_ok=True)

    required_files = ['android_debug.apk', 'android_release.apk', 'version.txt']
    missing = [f for f in required_files if not os.path.exists(os.path.join(target_dir, f))]

    if not missing:
        print("All required Godot 4.3 Android templates are already present in:", target_dir)
        return True

    print(f"Missing templates: {missing}. Downloading from Godot releases...")
    initial_url = "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz"
    req = urllib.request.Request(initial_url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        final_url = resp.url
        total_len = int(resp.headers.get('Content-Length', 0))

    print(f"Connected to release asset. Total archive size: {total_len / (1024*1024):.1f} MB")
    stream = BufferedRangeHTTPFile(final_url, total_len)
    zf = zipfile.ZipFile(stream)

    for req_name in missing:
        archive_path = f"templates/{req_name}"
        if archive_path not in zf.namelist():
            print(f"Warning: {archive_path} not found in zip")
            continue
        dest_path = os.path.join(target_dir, req_name)
        info = zf.getinfo(archive_path)
        print(f"Extracting {req_name} ({info.file_size / (1024*1024):.1f} MB) -> {dest_path}...")
        with zf.open(archive_path) as src, open(dest_path, 'wb') as dst:
            shutil.copyfileobj(src, dst, length=1024*1024)
        print(f"Extracted {req_name} successfully.")

    # Also extract android_source.zip if present
    source_name = 'android_source.zip'
    dest_source = os.path.join(target_dir, source_name)
    archive_source = f"templates/{source_name}"
    if not os.path.exists(dest_source) and archive_source in zf.namelist():
        info = zf.getinfo(archive_source)
        print(f"Extracting {source_name} ({info.file_size / (1024*1024):.1f} MB)...")
        with zf.open(archive_source) as src, open(dest_source, 'wb') as dst:
            shutil.copyfileobj(src, dst, length=1024*1024)
        print(f"Extracted {source_name} successfully.")

    print("Template setup completed!")
    return True

if __name__ == '__main__':
    setup_templates()
