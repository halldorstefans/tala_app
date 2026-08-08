# Backlog

Pending work, grouped by phase. Phase 2 is done bar some deferred polish;
Phase 3 (largely reassembly-era) is the current focus; Phase 4 is "design the
schema/architecture to allow it, but don't build it yet."

For the *why* behind a decision, `DESIGN.md` and `tala_design_core.md` still hold product/UX intent.

## Standing decisions & constraints

Carry these into any new work so choices stay consistent:

- **Local-first.** SQLite via Drift; the Go/Postgres backend is a stub (dead
  schema) and not wired up. Tests use in-memory fakes, not SQLite.
- **One project per job.** `jobs.project_id` (nullable), not a join table —
  clean cost/progress partitions. (The backend still has a `project_jobs`
  table; reconcile before any sync — see Phase 4.)
- **`Job.cost` = "Other cost"** — non-part spend (machine shop, paint,
  consumables). Total job cost will be Other + Σ parts once Parts lands.
- **No FK enforcement.** No `PRAGMA foreign_keys`; cascades are done manually
  in the repositories (e.g. deleting a project unassigns its jobs).
- **Migrations exist now.** `schemaVersion` is at 3 with a `MigrationStrategy`
  (v2 projects, v3 parts). New tables/columns bump the version and add an
  `onUpgrade` step.

---

## Phase 2 — Organization & Tracking ✅ (deferred polish aside)

- **Active Work section** ✅ Done — in-progress jobs on the vehicle page.
- **Projects** ✅ Done — group a vehicle's jobs into phases; project detail,
  job assignment via the job form, Active Projects summary.

- **Backup & restore** ✅ Done (PR #4) — export a ZIP (`VACUUM INTO` db +
  photos) via the OS share sheet; stage-then-restart restore. Deferred: a
  periodic backup reminder.

- **Parts** ✅ Done (PR #5) — `parts` catalogue + `job_parts` (unit cost,
  quantity, purchase date) + optional `part_photos` on the part. Parts on the
  job with a Parts/Other/Total cost card; add inline or reuse from a searchable
  catalogue; edit parts and per-line cost/qty/date. `Job.cost` reframed as
  "Other cost". Deferred: a per-vehicle "parts used" list; hard dedup (search-
  to-reuse only). `part_photos` folds into the future Attachments migration
  (see Phase 3).

- **Cost rollups** ✅ Done (with Parts) — per-job Parts/Other/Total; parts
  folded into the per-vehicle and per-project totals.

- **Deferred polish** (small, do opportunistically):
  - ✅ Project-side "manage jobs" UI (PR #6).
  - ✅ Progress bar + status/cost on the project list cards (PR #6).
  - Per-vehicle "parts used" list (distinct parts + total spent; the
    `getPartsForVehicle` helper already backs it) — only one still open.

---

## Phase 3 — Photos & Documentation ← current

Mostly reassembly-era. **Attachments → Gallery → Annotations is a strict build
order** — all operate on the photo model, so do them together to avoid
reworking the gallery/annotations across the `job_photos` migration.

- **Attachments (generalized)** — the foundation. Polymorphic `attachments`
  table linking to vehicle / project / job with a `type` (photo, receipt,
  document, other) + caption. Migrate existing `job_photos` **and**
  `part_photos` in, and move the on-disk photo plumbing (storage path,
  cascade-delete-files) into this layer. Riskiest item (data migration +
  rewrite of photo wiring); do it as its own slice. Add a **`part_id`** so part
  photos fold in — the current backend schema has vehicle/project/job only, so
  reconcile that too (see Phase 4 debt). A parts *receipt*, lacking a part
  link, still attaches to the job.

- **Better photo gallery** — full-screen viewer with swipe + pinch-to-zoom
  (`photo_view: ^0.15.0` already in deps). A timeline view across all jobs as a
  visual restoration history. Depends on Attachments.

- **Photo annotations** — draw overlays / text labels, stored as a separate
  layer with the original preserved. Especially useful for the wiring loom
  (photo in place → mark which wire goes where → refer back at reassembly).
  Biggest single build in this phase. Depends on Attachments.

- **Search** — full-text across job titles, descriptions, notes (SQLite FTS or
  a simple in-memory `contains`). Lowest urgency here; the job list already has
  status/category/date filters. Slot in whenever.

---

## Phase 4 — Future (design for, don't build yet)

Keep the schema/architecture compatible; don't implement now.

- **Sync layer to the Go backend** — local-first with push-to-server; conflict
  strategy TBD. UUID PKs + `updated_at` on every table keep this feasible.
  **Debt to clear first:** reconcile the backend schema with the app's model
  — drop `project_jobs`, add `jobs.project_id` (one project per job); and add
  `attachments.part_id` once part photos exist. All unimplemented server-side,
  so cheap, but sync breaks on those tables until it's done.
- **Sensor data ingestion** — BLE battery readings, GPS tracks. Likely a
  separate time-series table (TimescaleDB server-side); app receives BLE, stores
  locally, then syncs.
- **Reminders / notifications** — time- or mileage-based maintenance. More
  relevant once the car is running and driven.
- **Multi-vehicle** — schema already supports it; UI needs a vehicle selector.
  YAGNI on a single car for now.
- **Cross-vehicle "what's next" / planned-work view** — a to-do list of planned
  jobs spanning vehicles (a per-vehicle planned filter already exists). Only
  earns its keep once there are multiple vehicles, so it rides with
  Multi-vehicle.
- **Web interface** — review logs on a laptop; needs the Go backend + a simple
  frontend.
