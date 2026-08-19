# Book Hub — Specification (MVP)

> Personal digital library & document management platform.
> Dominio propio, código original, datos sintéticos.

## 1. Problema

Colección física/digital heterogénea (libros, manuales, revistas, apuntes,
escaneos, PDFs, fotos) que no es organizable, portable ni confiable: sin
metadata, sin checksums, atrapada en apps.

Book Hub convierte cualquier documento en un recurso bibliotecario estructurado:
archivo íntegro (SHA-256), metadata con origen y confianza, revisión humana,
organización, búsqueda y exportación estándar sin lock-in.

## 2. Tesis central

La metadata extraída por máquina nunca es verdad hasta que el humano la
confirma. Book Hub registra de dónde salió cada campo (`pdf_dict`, `xmp`,
heurística de texto, filename) y con qué confianza; luego exige revisión
antes de considerar la ficha final.

## 3. MVP — flujo vertical

```
Upload (multipart)
  ↓ validación (magic bytes, mime, tamaño) + sha256 + dedup
  ↓ ProcessingJob (pending)
  ↓ [Python worker] classifier (kind/source) → extractor (pypdf) → normalizer → scorer
  ↓ extraction JSON + confidence + warnings → job completed
  ↓ Item.metadata_status = needs_review
  ↓ usuario revisa/corrige (PATCH) → reviewed
  ↓ indexado: búsqueda, colecciones/tags, export OPDS + ZIP
```

Sin OCR, sin frontend, sin DE/Parquet en el MVP.

## 4. Modelo de datos

```
users
  id, email (uniq), password_digest

items
  id, title, authors text[], isbn, publisher, year, language,
  genre, description, page_count, identifiers jsonb,
  kind (book|magazine|manual|document|scan|image),
  source (born_digital|physical_scan),
  metadata_status (pending|needs_review|reviewed),
  created_at, updated_at

document_files
  id, item_id (FK), storage_key (sha256-addressed, uniq),
  sha256, mime_type, size_bytes, original_filename, created_at

collections
  id, name (uniq), created_at

collection_items
  collection_id (FK), item_id (FK), UNIQUE(collection_id, item_id)

tags
  id, name (uniq)

item_tags
  item_id (FK), tag_id (FK), UNIQUE(item_id, tag_id)

processing_jobs
  id, item_id (FK, UNIQUE), status (pending|processing|completed|failed),
  error_message, error_details jsonb,
  extraction jsonb, confidence jsonb, warnings jsonb,
  started_at, completed_at, created_at
```

- `processing_jobs.item_id` UNIQUE = guarda de doble procesamiento.
- Authors como `text[]` (sin tabla normalizada en MVP).
- Bibliotila única implícita (single user); `Library` se añade si aparece multi-library.

## 5. Endpoints

| Método | Ruta | Acción |
|---|---|---|
| POST | `/api/v1/login` | JWT HS256 (email+password) |
| POST | `/api/v1/items` | crear Item (metadata básica opcional) |
| GET | `/api/v1/items` | listar/buscar (q, kind, language, tag, collection, page) |
| GET | `/api/v1/items/:id` | detalle |
| PATCH | `/api/v1/items/:id` | revisar/confirmar metadata → reviewed |
| POST | `/api/v1/items/:id/files` | subir archivo (multipart) |
| GET | `/api/v1/files/:id` | descargar archivo |
| POST | `/api/v1/items/:id/process` | crear job (409 si existe) |
| GET | `/api/v1/processing_jobs/:id` | estado + extraction/confidence |
| POST | `/api/v1/collections` | crear collection |
| POST | `/api/v1/collections/:id/items` | añadir item |
| POST | `/api/v1/items/:id/tags` | asignar tag |
| GET | `/api/v1/export/opds` | catálogo OPDS 2.0 |
| GET | `/api/v1/export/archive` | ZIP + manifest.json + files |

## 6. Autenticación

JWT HS256, secreto por env, 1 usuario seed. RS512/MFA/SSO diferidos (misma
justificación que en la iteración anterior: overhead sin valor en single-user
local).

## 7. Metadata

**Extraída (machine)** → `processing_jobs.extraction` JSON: valor +
`confidence` + `source` + `warnings`.

**Confirmada (human)** → columnas tipadas de `items`. El usuario es la única
fuente de verdad.

Campos extraíbles: title, authors, isbn (regex + validación checksum),
publisher, year, language, page_count, identifiers. No extraíbles: genre,
description (usuario). `metadata_status` controla el flujo
`pending → needs_review → reviewed`.

## 8. Storage

- Metadata → PostgreSQL.
- Archivos → `StorageAdapter` (interface: store/retrieve/delete/stat).
  - `LocalStorageAdapter` ahora (directorio `storage/files/<sha[0:2]>/<sha256>`).
  - `S3StorageAdapter` después (swap por env, sin tocar dominio).
- Content-addressed por sha256 → dedup gratis + integridad verificable.

## 9. Búsqueda (MVP)

ILIKE en title/authors, ISBN exacto, tags (overlap), filtros kind/language,
paginación. Sin FTS en MVP.

## 10. Export (MVP)

- **OPDS 2.0** (`application/opds+json`): feed con metadata schema.org,
  acquisition links, search template, paginación.
- **ZIP + manifest**: `manifest.json` (metadata confirmada + checksums +
  paths), `files/`, `README`. Sirve de backup/restore portable.

CSV, EPUB/PDF sidecar y filesystem layout → fases posteriores.

## 11. Data Engineering (diferido, no MVP)

Dataset derivado (metadata confirmada → parquet particionado → DuckDB) para
estadísticas de la biblioteca: calidad/completitud de metadata, distribución
por autor/idioma/año/categoría, tamaño por tipo, actividad de digitalización,
dedup. Útil de verdad, pero solo aporta con items reales → **Fase 2**. DuckDB
local → Athena en AWS sin reescribir.

## 12. Stack

Rails 7.2 API-only · Ruby 3.3 · PostgreSQL 16 · Python 3.13 · pypdf · Pillow ·
Docker Compose · minitest/pytest · RuboCop/ruff · Trivy/Semgrep.

## 13. Docker Compose

3 servicios: `db` (postgres:16-alpine, healthcheck), `api` (Puma :3000),
`worker` (poller Python). Volúmenes compartidos: `storage/files`,
`storage/uploads`, `storage/exports`.

## 14. Seed sintético

Script Python (`data/seed/generate_pdfs.py`, semilla fija `2026`): genera
PDFs born-digital (con y sin metadata), un PDF corrupto (path de error) y una
imagen (simula escaneo). Rails task crea User + Items + jobs. Nada real.

## 15. Criterios de aceptación

1. Login JWT funciona (401 sin token).
2. Upload PDF → Item + File con sha256 correcto; duplicado → sin segundo File (dedup).
3. Job pasa pending→processing→completed; estado consultable.
4. PDF born-digital con metadata → title/autor/páginas extraídos con confidence + source.
5. Escaneo/imagen → needs_review, sin extracción falsa.
6. Edito/confirmo metadata → reviewed.
7. Búsqueda por título/autor/ISBN/tag + filtros funcionan.
8. Collection + tags asignables.
9. OPDS 2.0 feed válido (schema) con acquisition links.
10. ZIP export con manifest + files + checksums verificables.
11. PDF corrupto → job failed con error claro, Item intacto.
12. Seed reproduce todo desde cero (`down -v && up`).
13. Tests Rails + Python verdes; CI con lint + tests + docker build + trivy + semgrep.
14. Re-ejecución del pipeline no duplica (UNIQUE item_id).

## 16. Deferred Features

- Dataset parquet + DuckDB (estadísticas), CSV export, restore desde manifest.
- OCR (Tesseract) para escaneos → full-text + búsqueda en OCR.
- Frontend Next.js.
- AWS: StorageAdapter S3, SQS + Lambda/ECS, Athena. Terraform.
- Postgres FTS, búsqueda semántica, vector DBs.
- Multi-library, autores normalizados, EPUB/PDF sidecar, sincronización multi-destino.
- MFA, SSO, RS512.

## 17. Honestidad

Existen Calibre, Zotero, Kavita. Book Hub es un ejercicio de ingeniería que
además sirve para la biblioteca personal de su autor. El valor está en el
pipeline de metadata con confianza, portabilidad OPDS/manifest,
checksum/dedup content-addressed y las decisiones de arquitectura. No pretende
desbancar herramientas existentes.

## 18. Fases de implementación

0. **Rebrand** — TracePack → Book Hub, docs, rename workers. Verificar compose + tests. *(hecho)*
1. **Domain Rails** — modelos + migraciones + constraints + validaciones + tests.
2. **Auth + API** — JWT HS256, upload, items, files, collections, tags, jobs, PATCH.
3. **Seed sintético** — PDFs sintéticos (pypdf/reportlab, semilla fija).
4. **Worker Python** — claim atómico, polling, classifier, extractor, normalizer, scorer.
5. **Search + organización + export** — búsqueda, collections/tags, OPDS 2.0, ZIP manifest.
6. **End-to-end + errores** — paths de éxito y error, dedup, idempotencia.
7. **Tests completos + coverage** — thresholds tras medir.
8. **CI** — RuboCop, ruff, tests, docker build, Trivy, Semgrep.
9. **Docs** — architecture.md, runbook.md, README completo.