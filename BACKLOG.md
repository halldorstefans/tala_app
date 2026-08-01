# Backlog

Pending work, grouped by phase. Phase 2 is the current focus; Phase 3 is the
next body of work (largely reassembly-era); Phase 4 is "design the schema/
architecture to allow it, but don't build it yet."

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
- **Migrations exist now.** `schemaVersion` is at 2 with a `MigrationStrategy`
  (added in the Projects slice). New tables/columns bump the version and add an
  `onUpgrade` step.

---

## Phase 2 — Organization & Tracking (current)

- **Active Work section** ✅ Done — in-progress jobs on the vehicle page.
- **Projects** ✅ Done — group a vehicle's jobs into phases; project detail,
  job assignment via the job form, Active Projects summary.

- **Backup / export** ← next. The safety net: a broken phone shouldn't lose
  months of logs. Export the full database as a raw SQLite copy and/or JSON,
  plus the photos directory, to device storage. A one-tap "backup
  now" button (optionally a periodic reminder); restore replaces the current
  database. No schema change. Needs a share/save dependency (`share_plus` or
  `file_picker` — neither is in `pubspec` yet).

- **Parts + job_parts** ⏸ On hold (nothing being bought mid-teardown). Two
  tables (`parts` catalogue + `job_parts` link with `unit_cost`, `quantity`,
  `purchase_date`); compute `total_cost` in Dart. Relabel the job form's
  `Cost` field → `Other cost`. Resume when parts start flowing.
  - **Part photos** (optional, 0..n): a `part_photos` table linked to
    `parts.id`, mirroring the existing `job_photos` infra (upload/compress via
    `photo_compressor`, display via `AppImage`, cascade-delete). Photos live on
    the *part* (reusable catalogue entry — a picture of the part, its box, the
    part-number label), so they follow the part wherever it's used. A photo is
    never required; parts themselves stay optional on a job. No dependency on
    Attachments — reuses the proven per-feature photo pattern; the future
    Attachments migration folds `part_photos` in (see Phase 3).

- **Cost rollups** — gated on Parts. Per-job = Other + Σ parts; fold parts into
  the per-project and per-vehicle totals (which already sum `job.cost`).
  Little to do until Parts lands.

- **Deferred polish** (small, do opportunistically):
  - Project-side bulk "manage jobs" UI (assignment is already covered by the
    job-form Project dropdown).
  - Progress/cost on the project **list** cards (currently only on detail).
  - Cross-vehicle "what's next" / planned-work view (deferred while single-car;
    revisit with multiple vehicles or as a project-grouped view).
  - **Nit:** job detail prints `Cost: $…` (`job_detail_screen.dart:215`) while
    the rest of the app uses `€` — standardise on `€` (parked in the Parts
    relabel, but cheap to fix independently).

---

## Phase 3 — Photos & Documentation

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
- **Web interface** — review logs on a laptop; needs the Go backend + a simple
  frontend.
