# Backlog

Pending work, roughly highest-value / most-ready first. Completed work lives in
git history and the merged PRs. For the *why* behind product/UX decisions, see
`DESIGN.md` and `tala_design_core.md`.

## Standing decisions & constraints

Carry these into any new work so choices stay consistent:

- **Local-first.** All data is on-device in SQLite via Drift. There is no
  network layer; a future self-hosted (Go/Postgres) sync backend is *designed
  for* — UUID primary keys + `updated_at` on every table — but not built.
- **One project per job.** `jobs.project_id` (nullable), not a join table —
  clean cost/progress partitions. A job can also stand alone, unassigned.
- **`Job.cost` = "Other cost."** Non-part spend (machine shop, paint,
  consumables). Total job cost is Other + Σ parts.
- **No FK enforcement.** No `PRAGMA foreign_keys`; cascades are done manually in
  the repositories — deleting a vehicle/job/part removes its rows *and* its
  files from disk.
- **Migrations.** `schemaVersion` is at 4 (`MigrationStrategy`: v2 projects, v3
  parts, v4 attachments). New tables/columns bump the version and add an
  `onUpgrade` step; migrations are covered by a real-SQLite test.
- **Testing.** ViewModel/widget tests use in-memory fakes; repository and
  migration tests run against a real in-memory SQLite (`AppDatabase.forTesting`
  + `NativeDatabase.memory()`).

---

## Ready to build

Local-only and incremental — no backend, hardware, or extra groundwork needed.

- **Search.** Full-text across job titles, descriptions, and notes (SQLite FTS
  or a simple in-memory `contains`). The job list already has status/category/
  date filters, so this is the "find that one note about the heater valve three
  months later" case. Self-contained and increasingly useful as the log fills
  up — the strongest next build.

- **Photo gallery / timeline.** A per-vehicle visual restoration history: the
  image attachments across a vehicle's jobs, ordered by date. Read-only view
  over data already stored; the full-screen swipe + pinch-zoom viewer already
  ships in `AttachmentsSection`, so only the timeline layout is new.

- **Photo annotations.** Draw overlays / text labels over a photo, with the
  original preserved (a separate annotation layer). Especially useful for the
  wiring loom — mark which wire goes where, refer back at reassembly. The
  largest of these: needs a drawing canvas plus a way to store and render the
  overlay.

- **Periodic backup reminder.** A gentle nudge to export a backup (e.g. after N
  days or N changes since the last one). Small; pairs with the existing
  backup/restore.

## Later / needs groundwork

Bigger, or blocked on something that doesn't exist yet — a backend, multiple
vehicles, or hardware.

- **Sync to a self-hosted backend.** Local-first with push-to-server; conflict
  strategy TBD. UUID PKs + `updated_at` keep it feasible. **Reconcile the
  backend schema first** so it matches the app's model: one `jobs.project_id`
  (no `project_jobs` join table) and an `attachments` table with a `part_id`.
  Cheap while unbuilt; sync breaks on those tables until it's done.

- **Multi-vehicle.** The schema already supports many vehicles and the home
  screen lists them; the UI just needs a proper vehicle selector. YAGNI on a
  single car for now.

- **Cross-vehicle "what's next" view.** A planned-work to-do list spanning
  vehicles (a per-vehicle planned filter already exists). Only earns its keep
  with multiple vehicles, so it rides with Multi-vehicle.

- **Sensor data ingestion.** BLE battery readings, GPS tracks — likely a
  separate time-series store. The app receives over BLE, stores locally, then
  syncs. More relevant once the car runs and is driven.

- **Maintenance reminders / notifications.** Time- or mileage-based service
  nudges. Also more relevant once the car is on the road.

- **Web interface.** Review the logbook on a laptop; needs the backend plus a
  simple frontend.
