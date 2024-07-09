import os
import shutil
import fnmatch
from datetime import datetime
import json


def env_array(key):
    return os.getenv(key).split(",") if os.getenv(key) else []


DEFAULT_EXTENSIONS = {
    "python": "*.py",
}

E_IGNORE_DIRS = env_array("IGNORE_DIRS")
E_IGNORE_FILES = env_array("IGNORE_FILES")
E_IGNORE_PATTERNS = env_array("IGNORE_PATTERNS")
E_SOURCE_DIR = os.getenv("SOURCE_DIR")
E_TECHNOLOGY = os.getenv("TECHNOLOGY")
OUTPUT_PATH = f"dist/{E_TECHNOLOGY}/veracode_static_sast_{datetime.now().strftime('%Y%m%d')}"
TECHNOLOGY_EXT = DEFAULT_EXTENSIONS[E_TECHNOLOGY]


def ignored(file, dirpath):
    if E_IGNORE_FILES and any(key in file for key in E_IGNORE_FILES):
        return True
    if E_IGNORE_PATTERNS and any(fnmatch.fnmatch(file, key) for key in E_IGNORE_PATTERNS):
        return True
    for key in E_IGNORE_DIRS:
        if fnmatch.fnmatch(dirpath, f'*{key}*'):
            return True
    return False


for dirpath, dirnames, filenames in os.walk(E_TECHNOLOGY):
    dirnames[:] = [d for d in dirnames if not ignored(d, dirpath)]
    for filename in filenames:
        if fnmatch.fnmatch(filename, TECHNOLOGY_EXT) and not ignored(filename, dirpath):
            src_path = os.path.join(dirpath, filename)
            dest_path = os.path.join(OUTPUT_PATH, os.path.relpath(src_path, E_TECHNOLOGY))
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)
            shutil.copy2(src_path, dest_path)

print(json.dumps({"output_file": OUTPUT_PATH.split("/")[-1]}))
