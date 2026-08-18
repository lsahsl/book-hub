# Runbook

Local-first project. All services run via Docker Compose.

## Commands

```bash
# first time (copies env template; set real secrets locally)
cp .env.example .env

# build and start
docker compose build
docker compose up -d

# inspect
docker compose ps
docker compose logs -f api

# stop
docker compose stop

# full reset (wipes database and storage, regenerates everything)
docker compose down -v
rm -rf storage/files/* storage/uploads/* storage/exports/*
docker compose up -d
```

## Service addresses

| Service | Address |
|---|---|
| API (Rails) | http://localhost:3000 |
| PostgreSQL | localhost:5432 (user/pass from `.env`) |

## Current phase verification

```bash
docker compose exec api bundle exec rails test     # smoke test passes
docker compose exec worker pytest                  # smoke test passes
docker compose exec db psql -U bookhub -c 'select version();'
```

## Demo (after Phase 6)

Documented here once the pipeline is connected. Planned flow:

1. `docker compose up -d`
2. seed synthetic library
3. register a PDF, start processing
4. poll status, review metadata, download OPDS/archive export