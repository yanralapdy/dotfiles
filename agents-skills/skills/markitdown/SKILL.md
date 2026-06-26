---
name: markitdown
description: Convert files (PDF, Word, Excel, PPT, HTML, images/OCR, audio/transcription, EPUB, ZIP, YouTube URLs, CSV, JSON, XML) to Markdown for LLM consumption. Use when the user asks to read, analyze, or convert a document file into text, or wants file contents as markdown.
allowed-tools: bash, read
---

# MarkItDown

Convert office documents and media files to Markdown via the `markitdown` CLI.

## Usage

```bash
# Convert a file, output to stdout (read with read tool)
markitdown <file>

# Convert and save to .md
markitdown <file> -o <output.md>

# From stdin
cat <file> | markitdown
```

## Supported formats

- **PDF** — text extraction
- **Word** (.docx) — with formatting
- **Excel** (.xlsx, .xls) — tables as markdown tables
- **PowerPoint** (.pptx) — slides as markdown
- **Images** — OCR text extraction + EXIF metadata
- **Audio** — speech transcription + EXIF metadata
- **HTML** — to markdown
- **EPUB** — ebook to markdown
- **ZIP** — iterates contents
- **YouTube URLs** — transcript extraction
- **CSV, JSON, XML** — as markdown

## Notes

- Installed at `/opt/homebrew/bin/markitdown` (Python 3.14)
- Large files may take time; prefer `-o` for big outputs
- OCR and transcription require the `[all]` extras (installed)
- For security, only run on user-provided files, not untrusted URLs
