#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
decrypt_pdf — remove the password from a PDF using qpdf

USAGE
    ./decrypt_pdf.sh -p <password> -f <book.pdf>
    ./decrypt_pdf.sh -h | --help

OPTIONS
    -p <password>   The password used to open the PDF.
                    Quote it if it contains spaces or shell metacharacters,
                    e.g. -p 'p@ss word!'.
    -f <book.pdf>   Path to the encrypted PDF. May be a bare filename in the
                    current directory or an absolute/relative path.
    -h, --help      Show this help and exit.

OUTPUT
    Writes <name>_unlocked.pdf next to the input file. For example:
        ./decrypt_pdf.sh -p 'secret' -f ~/Downloads/SEC560_Book1.pdf
        -> ~/Downloads/SEC560_Book1_unlocked.pdf

REQUIREMENTS
    qpdf must be installed and on PATH.
        Debian/Ubuntu/Kali/WSL:  sudo apt install qpdf
        macOS (Homebrew):        brew install qpdf

EXIT STATUS
    0   success
    1   bad usage, missing input, or qpdf failure (e.g. wrong password)

EXAMPLES
    ./decrypt_pdf.sh -p 'my-sans-password' -f SEC560_Book1.pdf
    ./decrypt_pdf.sh -f /mnt/c/Books/FOR578_Book2.pdf -p "$SANSPWD"
EOF
}

if [ $# -eq 1 ] && [ "$1" = "--help" ]; then
    usage
    exit 0
fi

PASSWORD=""
INPUT=""

while getopts ":p:f:h" opt; do
    case "$opt" in
        p) PASSWORD="$OPTARG" ;;
        f) INPUT="$OPTARG" ;;
        h) usage; exit 0 ;;
        :) echo "Error: -$OPTARG requires an argument" >&2; usage >&2; exit 1 ;;
        \?) echo "Error: unknown option -$OPTARG" >&2; usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -gt 0 ]; then
    echo "Error: unexpected positional argument(s): $*" >&2
    usage >&2
    exit 1
fi

if [ -z "$PASSWORD" ] || [ -z "$INPUT" ]; then
    echo "Error: both -p <password> and -f <book.pdf> are required" >&2
    usage >&2
    exit 1
fi

if [ ! -f "$INPUT" ]; then
    echo "Error: file not found: $INPUT" >&2
    exit 1
fi

DIR="$(dirname -- "$INPUT")"
BASE="$(basename -- "$INPUT")"
NAME="${BASE%.*}"
OUTPUT="$DIR/${NAME}_unlocked.pdf"

qpdf --password="$PASSWORD" --decrypt -- "$INPUT" "$OUTPUT"

echo "Created: $OUTPUT"
