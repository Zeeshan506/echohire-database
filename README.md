# EchoHire Database

Database and local infrastructure assets for EchoHire, an AI-powered recruitment and interview platform developed as a Final Year Project. This repository runs the platform's local PostgreSQL database and pgAdmin; it contains no application code or ORM models.

## Project Context

This is the database/infrastructure component of EchoHire. The expected application path is:

```text
Frontend → Backend → PostgreSQL
```

This repository establishes the database layer only; frontend, backend, and model integration code is outside its scope.

## Database Responsibilities

- Defines local PostgreSQL 17 and pgAdmin services with Docker Compose.
- Persists PostgreSQL data in the external Docker volume `database_echohire_data`.
- Runs `initdb/postgress_init.sql` on first initialization of an empty data volume. It creates user, candidate, recruiter, job, skill, application, and bookmark data structures and enables `uuid-ossp` and `pg_trgm`.

## Architecture

```text
EchoHire Frontend
       ↓
EchoHire Backend
       ↓
PostgreSQL (this repository)
```

Recommendation or model functionality may depend on storage exposed through the backend, but this repository does not currently define vector columns, embeddings, or model integration.

## PostgreSQL & pgvector

The current Compose service uses `postgres:17`. It does **not** use a pgvector-enabled image, and neither the bootstrap SQL nor the tracked files reference the `vector` extension. Therefore, pgvector support is not currently provided or configured by this repository.

## Initialization

Docker Compose exposes PostgreSQL on host port `5432` and pgAdmin on host port `8080` (container port `80`). Its services are named `postgres` and `pgadmin`.

Create the required external volume once, then start the services:

```bash
docker volume create database_echohire_data
docker compose up -d
```

On a new, empty volume, the PostgreSQL image initializes the database named by `POSTGRES_DB` using the supplied PostgreSQL user and password. It then runs the SQL files mounted at `/docker-entrypoint-initdb.d`, including `initdb/postgress_init.sql`. These scripts are not re-run for an existing populated volume.

## Schema Management

`alembic.ini` points to a local `migrations/` directory, but that directory and its migration environment are absent from this repository. This repository therefore does not contain an executable Alembic migration history. Schema migration ownership belongs with the EchoHire backend's Alembic workflow; do not duplicate migrations here without an explicit cross-repository decision.

## Repository Structure

```text
.
├── docker-compose.yml          # PostgreSQL and pgAdmin services
├── initdb/
│   └── postgress_init.sql      # First-run schema/bootstrap SQL
├── alembic.ini                 # References migrations/ (not present here)
└── .gitignore                  # Ignores local secrets and database backup
```

## Local Setup

1. Create `.env` with the required variable names.
2. Create the external volume: `docker volume create database_echohire_data`.
3. Start the stack: `docker compose up -d`.

PostgreSQL is available at `localhost:5432`; pgAdmin is available at `http://localhost:8080`.

## Environment Configuration

`docker-compose.yml` requires:

- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_DB`
- `PGADMIN_EMAIL`
- `PGADMIN_PASSWORD`

## Data / Backup Assets

No database backup is tracked in this repository. Store physical database snapshots outside Git in approved backup storage, with a documented restore procedure.

## Related Repositories

- Frontend: https://github.com/Zeeshan506/Echohire-Frontend
- Backend: https://github.com/Zeeshan506/Echohire-Backend
- Model: https://github.com/Zeeshan506/echohire-model

## Current Status

The repository currently supports a local PostgreSQL 17 and pgAdmin stack, an external persistent volume, and first-run relational-schema initialization with fuzzy-text search support. Usable local Alembic migrations and pgvector configuration are not currently present.

## Security Note

Production credentials and database data must not be committed to Git. Local `.env` files and database backup archives are ignored; use approved secret management and backup storage instead.
