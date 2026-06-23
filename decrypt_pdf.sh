#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
decrypt_pdf — remove the password from a PDF using qpdf

USAGE
    ./decrypt_pdf.sh -p <password> [-f <book.pdf>]
    ./decrypt_pdf.sh -h | --help

OPTIONS
    -p <password>   The password used to open the PDF.
                    Quote it if it contains spaces or shell metacharacters,
                    e.g. -p 'p@ss word!'.
    -f <book.pdf>   Path to a specific encrypted PDF. If omitted, all *.pdf
                    files in the current directory are decrypted.
    -h, --help      Show this help and exit.

OUTPUT
    Writes unlocked PDFs to a "Books Unlocked" folder in the parent directory
    of wherever the source PDFs live. For example, if PDFs are in:
        /mnt/c/Books/SEC560/
    unlocked files are written to:
        /mnt/c/Books/Books Unlocked/

REQUIREMENTS
    qpdf must be installed and on PATH.
        Debian/Ubuntu/Kali/WSL:  sudo apt install qpdf
        macOS (Homebrew):        brew install qpdf

EXIT STATUS
    0   success
    1   bad usage, missing input, or qpdf failure (e.g. wrong password)

EXAMPLES
    # Decrypt a single file
    ./decrypt_pdf.sh -p 'my-sans-password' -f SEC560_Book1.pdf

    # Decrypt all PDFs in the current directory
    ./decrypt_pdf.sh -p 'my-sans-password'
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

if [ -z "$PASSWORD" ]; then
    echo "Error: -p <password> is required" >&2
    usage >&2
    exit 1
fi

decrypt_file() {
    local file="$1"
    local out_dir="$2"

    local base
    base="$(basename -- "$file")"
    local name="${base%.*}"
    local output="$out_dir/${name}_unlocked.pdf"

    if qpdf --password="$PASSWORD" --decrypt -- "$file" "$output"; then
        echo "Created: $output"
    else
        echo "Error: qpdf failed for $file (wrong password?)" >&2
        return 1
    fi
}

if [ -n "$INPUT" ]; then
    # Single-file mode
    if [ ! -f "$INPUT" ]; then
        echo "Error: file not found: $INPUT" >&2
        exit 1
    fi
    SOURCE_DIR="$(cd "$(dirname -- "$INPUT")" && pwd)"
else
    # Batch mode — all PDFs in the current directory
    SOURCE_DIR="$(pwd)"
    mapfile -t pdfs < <(find "$SOURCE_DIR" -maxdepth 1 -iname "*.pdf" | sort)
    if [ ${#pdfs[@]} -eq 0 ]; then
        echo "Error: no PDF files found in $SOURCE_DIR" >&2
        exit 1
    fi
fi

OUT_DIR="$(dirname -- "$SOURCE_DIR")/Books Unlocked"
mkdir -p "$OUT_DIR"

if [ -n "$INPUT" ]; then
    decrypt_file "$INPUT" "$OUT_DIR"
else
    FAILED=0
    for pdf in "${pdfs[@]}"; do
        decrypt_file "$pdf" "$OUT_DIR" || FAILED=$((FAILED + 1))
    done
    echo ""
    echo "Done. ${#pdfs[@]} file(s) processed, $FAILED failed."
    echo "Output directory: $OUT_DIR"
    [ "$FAILED" -eq 0 ] || exit 1
fi
