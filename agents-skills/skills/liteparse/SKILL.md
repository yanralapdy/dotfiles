---
name: liteparse
description: Fast local document parsing (PDF, DOCX, XLSX, PPTX, Images) with spatial text extraction, OCR, and screenshot generation. Outputs markdown, JSON, or plain text. Use when the user needs fast document parsing, document screenshots for visual analysis, batch processing of documents, or spatial text extraction with bounding boxes. Prefer over markitdown when speed matters or spatial layout info is needed.
allowed-tools: bash, read
---

# LiteParse

Fast Rust-based PDF/document parser via the `liteparse` (or `lit`) CLI.

## Commands

### Parse a document
```bash
# Markdown output (best for LLM consumption)
liteparse parse <file> --format markdown

# JSON with bounding boxes
liteparse parse <file> --format json

# Plain text
liteparse parse <file> --format text

# Save to file
liteparse parse <file> --format markdown -o output.md

# Parse specific pages
liteparse parse <file> --target-pages "1-5,10" --format markdown

# With OCR
liteparse parse <file> --format markdown --ocr-server-url <url>
```

### Generate screenshots
```bash
liteparse screenshot <file> -o screenshots/
```

### Batch parse
```bash
liteparse batch-parse <input-dir> <output-dir> --format markdown
```

## Options
- `--format` — `markdown` (recommended for LLMs), `json` (spatial/bbox), `text`
- `--image-mode` — `off`, `placeholder`, `embed`
- `--target-pages` — range or list (e.g., `"1-5,10,15-20"`)
- `--no-ocr` — skip OCR (faster)
- `--dpi` — rendering DPI for screenshots/OCR
- `--password` — for encrypted PDFs

## Comparison with markitdown
- **LiteParse:** Faster (Rust), spatial text with bboxes, screenshots, batch mode, fewer format support
- **MarkItDown:** More format support (audio, EPUB, YouTube, ZIP), Python-based

## Notes
- Installed globally via npm: `liteparse` or `lit` command
- OCR requires an HTTP OCR server (Tesseract bundled, or plug external)
- Screenshots are PNG files, one per page
