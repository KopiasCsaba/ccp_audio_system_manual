# PDF Generation Scripts

Docker-based PDF generation from markdown files.

## Quick Start

```bash
# Build Docker image (first time only)
./scripts/build.sh

# Generate PDFs (only converts modified files)
./scripts/convert.sh

# Regenerate ALL PDFs (ignores timestamps)
./scripts/convert.sh all
```

## Files

- `build.sh` - Builds the Docker image with all dependencies
- `convert.sh` - Runs PDF generation in Docker
- `Dockerfile` - Image definition (Ubuntu + pandoc + texlive + brave-browser)
- `internal/` - Internal scripts (called by convert.sh)
  - `gen_all.sh` - Finds and processes all markdown files
  - `md_to_pdf.sh` - Converts single markdown to PDF
  - `setup.sh` - Original setup script (archived)

## What It Does

Converts all markdown files in `for_technicians/` to PDFs:
1. Markdown → HTML (via pandoc)
2. HTML → PDF (via brave-browser headless)
3. PDF → PDF with page numbers (via pdflatex)

Output PDFs are created next to their source `.md` files.

## Troubleshooting

Run test script to see verbose output:
```bash
./scripts/test-convert.sh
```
