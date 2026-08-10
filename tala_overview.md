# Tala

A local-first digital logbook for tracking vehicle maintenance and restoration work. Built for the garage — designed to be fast, offline, and useful with one hand.

Tala (Icelandic: *tala*, "number" / "to speak") runs entirely on your phone. No server, no account, no subscription. Your data lives on your device with manual backups to wherever you choose.

> **Status:** This document describes the app as it is **today**, followed by a
> **Roadmap** of what's planned. For the phase-by-phase breakdown and the *why*
> behind decisions, see [`BACKLOG.md`](BACKLOG.md), [`DESIGN.md`](DESIGN.md), and
> [`tala_design_core.md`](tala_design_core.md).

---

## What It Does Today

### Vehicles

Each vehicle has a profile: make, model, year, VIN, registration number, colour, nickname, odometer, purchase date, notes, and a cover photo. A dashboard shows the vehicle's current state at a glance — how many jobs are planned, in progress, and completed, and the total cost logged so far.

You can add more than one vehicle — a daily driver alongside a restoration project — and each keeps its own garage of jobs, projects, and parts.

### Jobs

A job is any unit of work on a vehicle — an oil change, a wiring repair, stripping the interior, fitting a new part. Each job records:

- Title and description
- Category (maintenance, repair, restoration, inspection, upgrade, electrical, bodywork, or custom)
- Status (planned, in progress, completed)
- Start date and completion date
- Odometer reading at time of work
- Cost ("Other cost" — non-part spend; see Cost Tracking)

Jobs are the core of the app. The job list is filterable by status, category, and date range, and sorted by date. Quick-add lets you create a job with just a title and a tap — category defaults to the most recently used, date defaults to today, and everything else can be filled in later from the detail screen.

### Projects

A project groups related jobs under a shared goal. "Interior strip," "Electrical rewire," "Suspension rebuild." Each project has a title, description, status, and start/end dates. A job belongs to at most one project, so projects partition the work into clean phases and costs roll up without double-counting. (A job can also stand alone, unassigned to any project.)

The project view shows its jobs, a progress summary (planned/in progress/completed counts), and a rolled-up cost total.

### Parts

Parts track what was used and where it came from. Each part records a name, part number, brand, supplier, and notes. Parts are linked to jobs with quantity, unit cost, and purchase date; the line total is calculated automatically.

Parts are reusable: if you buy the same oil filter for multiple services, you define the part once — searching the catalogue to reuse it — and link it to each job with its own cost and quantity. A per-vehicle "parts used" list rolls up quantity and spend across the vehicle.

### Photos

Photos are stored locally on the device, compressed on capture. A vehicle has a cover photo; jobs and parts can carry photos of their own. On a job, tapping a photo opens a full-screen viewer with pinch-to-zoom.

Deleting a job or vehicle removes its photo files from disk (not just the database rows), so nothing is orphaned.

### Cost Tracking

Costs are tracked at three levels. Each job has a direct "Other cost" field (machine shop, paint, consumables — non-part spend). Parts linked to a job contribute their own calculated cost (unit cost × quantity). The total job cost is the sum of both.

Projects roll up the costs of their jobs. The vehicle dashboard shows the cumulative total across all jobs. No complex budgeting or forecasting — just a clear, honest picture of what the work has cost.

### Backup & Export

The full database and all photos can be exported as a single ZIP file through the OS share sheet — save it to local storage or a file-sync service. Restoring from a backup stages the archive and swaps it in on the next launch, replacing the current database and photos.

No cloud sync, no automatic uploads. You control when and where your data goes.

---

## Roadmap

Planned but **not yet built**. Kept here so the vision is visible; see
[`BACKLOG.md`](BACKLOG.md) for phasing and status.

- **Attachments (generalized)** — photos, receipts, documents, and other files
  attached at the vehicle, project, or job level, each with a type and an
  optional caption. Today's job/part/vehicle photos fold into this.
- **Better photo gallery** — a full-screen gallery with swipe navigation and a
  timeline view across all jobs as a visual restoration history.
- **Photo annotations** — drawn overlays and text labels stored as a separate
  layer over the original, for documenting things like a wiring loom.
- **Search** — full-text across job titles, descriptions, and notes. (Today,
  only the parts catalogue is searchable, for reuse.)
- **Planned-work view** — a dedicated to-do view of "planned" jobs. (Today,
  planned jobs are reachable via the job-list status filter.)
- **Sync** — optional local-first sync to a self-hosted Go/PostgreSQL backend.
  UUID primary keys and `updated_at` timestamps on every table are in place to
  keep this feasible.
- **Sensor data, reminders, web interface** — later, once the car is running
  and driven.

---

## Technical Summary

- **Platform:** Android (Flutter). iOS/web/desktop build via Flutter but aren't actively tested.
- **Data layer:** SQLite via drift, with repository interfaces abstracting storage.
- **Photos:** stored in the app documents directory, compressed on capture via flutter_image_compress.
- **Architecture:** local-first, offline-capable, no network dependency. The app opens straight to your garage — no account or sign-in.
- **Sync-ready:** UUID primary keys and `updated_at` timestamps on all tables, designed for a future optional sync layer (see Roadmap).

---

## What It Doesn't Do (Yet)

- Sync to a server — see Roadmap.
- Generalized attachments, photo annotations, or global full-text search — see Roadmap.
- Ingest sensor data (battery voltage, GPS).
- Send reminders or notifications.
- Require an account or sign-in — Tala is single-user and local by design.
- Run on iOS or web (Flutter supports both; the app is Android-only for now).
