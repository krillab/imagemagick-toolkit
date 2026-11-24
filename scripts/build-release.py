#!/usr/bin/env python3
"""Build a single-folder skill ZIP using only the Python standard library."""
import hashlib
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]
EXCLUDED = {".git", ".svn", "dist", "__pycache__", ".test-output"}

def main():
    destination = ROOT / "dist"
    destination.mkdir(exist_ok=True)
    archive = destination / (ROOT.name + ".zip")
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as bundle:
        for path in sorted(ROOT.rglob("*")):
            relative = path.relative_to(ROOT)
            if any(part in EXCLUDED for part in relative.parts):
                continue
            if path.is_symlink():
                raise ValueError("Refusing symlink: " + str(relative))
            if not path.is_file() or path.suffix == ".pyc":
                continue
            info = zipfile.ZipInfo((Path(ROOT.name) / relative).as_posix())
            info.date_time = (2026, 1, 1, 0, 0, 0)
            info.create_system = 3
            info.external_attr = (0o100755 if path.suffix == ".sh" else 0o100644) << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            bundle.writestr(info, path.read_bytes(), compresslevel=9)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    checksum = archive.with_suffix(".zip.sha256")
    checksum.write_text(digest + "  " + archive.name + "\n", encoding="ascii")
    print(str(archive))
    print(str(archive.stat().st_size) + " bytes")
    print("SHA256 " + digest)

if __name__ == "__main__":
    main()
