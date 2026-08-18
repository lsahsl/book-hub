# Book Hub

Personal digital library & document management platform.

Book Hub turns a heterogeneous collection (books, manuals, magazines, notes,
scans, PDFs, photos of documents) into an organized, portable library: every
document becomes a structured resource with an intact file (SHA-256 checksum),
metadata with a visible source and confidence score, human review, search,
collections, and standards-based export.

> Fictional/data-free by design for the seed; your own library lives in
> gitignored storage. Code and design are original — nothing here relates to
> any employer's codebase.

## The core idea

Machine-extracted metadata is never truth until a human confirms it. Book Hub
records **where** each metadata field came from (`pdf_dict`, `xmp`, text
heuristic, filename) and with **what confidence**, then asks the user to
review before the item is considered finalized. Storage is content-addressed
(SHA-256), so duplicates are free to detect and integrity is verifiable.

## Stack

- API: Rails 7.2 (API-only), Ruby 3.3, PostgreSQL 16
- Workers: Python 3.13 (pypdf, Pillow)
- Local: Docker Compose
- Export: OPDS 2.0 feed + ZIP manifest

## Status

Phase 0 (rebrand + scaffold) complete. See `docs/specification.md` and
`docs/checkpoints/` for the roadmap and phase notes.

## Quick start

```bash
cp .env.example .env
docker compose build
docker compose up -d
docker compose ps
```

Full demo commands and API usage: `docs/runbook.md`.