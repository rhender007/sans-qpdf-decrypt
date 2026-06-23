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
Replace filenames as needed. The new file opens without any password prompt.

## Included script: `decrypt_pdf.sh`

A helper script that handles both single-file and batch decryption. Unlocked files are always written to a **`Books Unlocked`** folder created in the parent directory of wherever the source PDFs live.

Make it executable once:
```bash
chmod +x decrypt_pdf.sh
```

### Usage

```bash
./decrypt_pdf.sh -p <password> [-f <book.pdf>]
```

### Flags

| Flag | Description |
|------|-------------|
| `-p <password>` | The PDF's open password. Quote it if it contains spaces or special characters (`!`, `$`, `&`, etc.). **Required.** |
| `-f <book.pdf>` | Path to a specific PDF to decrypt. If omitted, all `*.pdf` files in the current directory are decrypted. |
| `-h`, `--help` | Show built-in help and exit. |

### Output location

Unlocked PDFs are written to a `Books Unlocked` folder in the **parent** of the source directory, created automatically if it doesn't exist.

```
/mnt/c/Books/
├── SEC560/
│   ├── SEC560_Book1.pdf          ← input
│   └── SEC560_Book2.pdf          ← input
└── Books Unlocked/
    ├── SEC560_Book1_unlocked.pdf ← output
    └── SEC560_Book2_unlocked.pdf ← output
```

### Examples

```bash
# Decrypt a single file
./decrypt_pdf.sh -p 'my-sans-password' -f SEC560_Book1.pdf

# Decrypt all PDFs in the current directory (batch mode)
./decrypt_pdf.sh -p 'my-sans-password'

# Use a password stored in an environment variable
export SANSPWD='my-sans-password'
./decrypt_pdf.sh -p "$SANSPWD" -f FOR578_Book2.pdf

# Show built-in help
./decrypt_pdf.sh --help
```
