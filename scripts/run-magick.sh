#!/bin/sh
# POSIX launcher; Windows runtime is intentionally not selected here.
set -eu
if [ "$#" -eq 0 ]; then
    echo "Pass ImageMagick arguments, for example: -version" >&2
    exit 2
fi
if [ -n "${IMAGEMAGICK_EXECUTABLE:-}" ]; then
    case "$IMAGEMAGICK_EXECUTABLE" in
        /*) ;;
        *) echo "IMAGEMAGICK_EXECUTABLE must be an absolute path." >&2; exit 1 ;;
    esac
    if [ ! -f "$IMAGEMAGICK_EXECUTABLE" ] || [ ! -x "$IMAGEMAGICK_EXECUTABLE" ]; then
        echo "IMAGEMAGICK_EXECUTABLE is missing or not executable." >&2
        exit 1
    fi
    exec "$IMAGEMAGICK_EXECUTABLE" "$@"
fi
if ! command -v magick >/dev/null 2>&1; then
    echo "ImageMagick 7 is not installed. See references/installation.md." >&2
    exit 127
fi
exec magick "$@"
