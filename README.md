# SANS Workbook Password Removal (using qpdf)

Tired of typing the same password every time you open a SANS electronic workbook (SEC560, FOR578, etc.)?

This repo contains a dead-simple one-liner + optional bash script to decrypt the PDF **once** using your known password — creating an unprotected version you can use without prompts.

## Important legal note   
Only use this on SANS materials you have legitimately purchased / received access to. Do **NOT** share decrypted PDFs. Violation of the Courseware License Agreement could result in financial liability and decertification.

## Requirements
- Ubuntu, Debian, Kali, WSL, macOS, or any Linux/macOS system
- `qpdf` installed

```bash
# Ubuntu / Debian / WSL / Kali
sudo apt update && sudo apt install qpdf -y

# macOS (with Homebrew)
brew install qpdf
```
## One-liner method (what most people use)
```bash
export SANSPWD='your-actual-sans-password-here'
qpdf --password="$SANSPWD" --decrypt ./SEC560_GPEN_Book1.pdf ./SEC560_GPEN_Book1_NoPass.pdf
```
Replace filenames as needed. After this runs successfully:

The new file (*_NoPass.pdf) opens without any password prompt.
You can delete or archive the original encrypted version.
## Included script: `decrypt_pdf.sh`

This repo ships a small helper that takes the password and the PDF path as arguments and writes `<name>_unlocked.pdf` next to the original.

Make it executable once:
```bash
chmod +x decrypt_pdf.sh
```

Usage:
```bash
./decrypt_pdf.sh -p <password> -f <book.pdf>
```

Flags:
- `-p <password>` — the PDF's open password. Quote it if it contains spaces or shell metacharacters (`!`, `$`, `&`, etc.).
- `-f <book.pdf>` — bare filename or absolute/relative path to the encrypted PDF.
- `-h`, `--help` — show built-in help.

Flag order doesn't matter.

Examples:
```bash
# Bare filename in the current directory
./decrypt_pdf.sh -p 'my-sans-password' -f SEC560_GPEN_Book1.pdf
# -> SEC560_GPEN_Book1_unlocked.pdf

# Full path — output lands next to the input
./decrypt_pdf.sh -f /mnt/c/Books/FOR578_Book2.pdf -p "$SANSPWD"
# -> /mnt/c/Books/FOR578_Book2_unlocked.pdf
```

Show built-in help:
```bash
./decrypt_pdf.sh --help
```
## Bulk decrypt (all PDFs in current folder)
If you have many books/sections:
```bash
export SANSPWD='your-password'
for f in *.pdf; do
    [ -f "$f" ] || continue  # skip if no PDFs
    OUTPUT="${f%.*}_nopass.pdf"
    qpdf --password="$SANSPWD" --decrypt "$f" "$OUTPUT"
    if [ $? -eq 0 ]; then
        echo "Decrypted: $OUTPUT"
    else
        echo "Failed: $f"
    fi
done
unset SANSPWD
```







