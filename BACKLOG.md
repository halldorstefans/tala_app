# Backlog

Active work for **Phase 1 — Garage MVP**. The goal of this phase is to make the app genuinely useful during restoration sessions: low friction, works with dirty hands and bad lighting.

Tickets are grouped by feature area. Each one is intended to be self-contained enough for a developer to pick up. Suggested order of attack: **1 → 2 → 3 → 4 → 5**, but they can be parallelised once the category constants from #2 land.

---

## 1. Quick-add job

**Goal:** Let the user create a job in as few taps as possible. Title, category, and date (default today) — everything else fillable later.

### 1a. Relax required fields on the job form
**File:** `lib/ui/job/form/widgets/job_form_screen.dart`

`description`, `odometer`, and `category` are all blocked by validators. Phase 1 wants only `title` required.

- Remove validators on `description`, `odometer`, and (after #2 lands) keep category validated against the predefined list when set but not required.
- Stop defaulting `_cost = 0.0` — leave null when the user hasn't entered one. (Same for `_odometer`.)
- The form currently defaults `_completionDate = DateTime.now()`. Default completion date to **null** — a brand-new job is "planned", not "completed today". Start date stays defaulted to today.
- Sanity-check the submit path: after `_addJob` succeeds, `widget.viewModel.job!.id` is dereferenced. If add fails this throws. Wrap the post-submit photo upload + navigation in a check that `viewModel.job != null`.

### 1b. Add a "Quick Add Job" entry point
**Files:** `lib/ui/home/widgets/home_screen.dart`, `lib/routing/router.dart`, `lib/routing/routes.dart`

Today, you can only add a job from inside a vehicle's job history screen. With a single MGB this is fine, but the spec calls for a persistent "+". Options (pick one):

- **Recommended:** When exactly one vehicle exists, the home-screen FAB becomes "Add Job" for that vehicle. When >1 vehicles exist, FAB opens a vehicle picker bottom sheet, then routes to the job form. The "Add Vehicle" action moves into an overflow menu.
- Alternative: dual FABs ("Add Job" / "Add Vehicle") via `SpeedDial` / `expandable_fab` package.

Decide with the project owner before building. Either way, the new entry point reuses `Routes.jobForm(vehicleId)`.

### 1c. (Optional, post-1a) "Quick-add" mini sheet
A bottom sheet variant of the form showing only title + category dropdown + start date, with a "More fields…" link that pushes the full form. Skip if 1a feels lean enough — the spec's bar is "title and a tap", which 1a alone gets close to.

---

## 2. Job categories

**Goal:** Predefined category set with free-text fallback. Required for filtering in #4.

### 2a. Define category constants
**New file:** `lib/domain/models/job_category.dart` (or extend `lib/domain/models/job.dart`)

```dart
abstract final class JobCategory {
  static const maintenance = 'maintenance';
  static const repair = 'repair';
  static const restoration = 'restoration';
  static const inspection = 'inspection';
  static const upgrade = 'upgrade';
  static const electrical = 'electrical';
  static const bodywork = 'bodywork';

  static const predefined = [
    maintenance, repair, restoration, inspection, upgrade, electrical, bodywork,
  ];
}
```

Pair with a `categoryLabel(String?)` helper for display (title-case + custom passthrough).

### 2b. Replace the category text field with a picker
**File:** `lib/ui/job/form/widgets/job_form_screen.dart`

- Replace the plain `TextFormField` with a `DropdownButtonFormField<String>` listing predefined categories plus a "Custom…" entry that reveals an inline `TextFormField`.
- Persist whatever string the user ends up with — the DB column is free text, so custom entries round-trip naturally.

### 2c. Surface category on the job card
Already lands as part of #3a (thumbnails + metadata redesign). Mention here so it's not missed.

---

## 3. Photo capture on jobs

**Goal:** Thumbnails on the list view; existing full-screen swipe viewer is fine.

### 3a. Add thumbnails + richer info to `JobCard`
**File:** `lib/ui/job/list/widgets/job_card.dart`

Current card is a bare `ListTile` with title + completion date. Redesign:

- Leading: first photo as a 56×56 thumbnail via `AppImage`. Falls back to a category icon (or generic wrench) when no photos.
- Title: `job.title`.
- Subtitle line 1: `category` (label) + `status` chip.
- Subtitle line 2: start date (formatted), or completion date if completed.
- Trailing: photo count badge ("+3") when more than one photo, else chevron.

Use `AppImage` (`lib/ui/core/widgets/app_image.dart`) — it already handles local-path resolution.

### 3b. Multi-pick from gallery (nice-to-have)
**File:** `lib/ui/job/form/widgets/job_form_screen.dart`

`image_picker` exposes `pickMultiImage()`. Swap `_pickPhoto(ImageSource.gallery)` to use it so users can select multiple shots in one pass. Camera flow stays single-shot.

### 3c. Move compression off the UI thread
**File:** `lib/ui/job/form/widgets/job_form_screen.dart`

`FlutterImageCompress.compressAndGetFile` runs sequentially per photo inside `_submit`'s `.then`. Pull the compress-then-upload loop into a helper on `JobFormViewModel` so the screen doesn't block on it, and so it's unit-testable. Show a small inline progress indicator while uploads run.

---

## 4. Job list with filtering and sorting

**Goal:** Filter by status, category, date range. Sort by start date (newest first) by default.

### 4a. Sort jobs newest-first at the data layer
**Files:** `lib/data/database/app_database.dart`, `lib/data/repositories/jobs/jobs_repository_local.dart`

`getJobsForVehicle` currently has no `orderBy`. Add `..orderBy([(t) => OrderingTerm(expression: t.startDate, mode: OrderingMode.desc)])`. Tiebreak by `createdAt desc`.

### 4b. Add filter state to `JobListViewModel`
**File:** `lib/ui/job/list/view_models/job_list_viewmodel.dart`

Hold filter state on the ViewModel:

```dart
Set<String> _statusFilter = {};      // empty = all
Set<String> _categoryFilter = {};    // empty = all
DateTimeRange? _dateRange;
```

Expose a `filteredJobs` getter that applies them in memory (job counts are small — no need to push this into SQL yet). `notifyListeners()` when filters change. Keep the raw `_jobs` list intact so toggling filters doesn't re-fetch.

### 4c. Filter UI on the job history screen
**File:** `lib/ui/job/list/widgets/job_history_screen.dart`

- A row of `FilterChip` controls under the AppBar for status (planned / in progress / completed). Multi-select.
- An `IconButton` (funnel icon) in the AppBar opens a bottom sheet for category multi-select (uses the constants from #2a) and date range (use `showDateRangePicker`).
- A clear-filters chip appears when any filter is active.
- The "isSummary" mode used by the vehicle dashboard stays unfiltered (uses raw list).

### 4d. Define canonical status strings
**Where:** alongside `JobCategory` in `lib/domain/models/`.

Today statuses are bare strings sprinkled in the form (`'planned'`). Define `JobStatus.planned / inProgress / completed` to mirror #2a so filter chips and dashboard counts agree on the values.

---

## 5. Vehicle dashboard

**Goal:** A single-screen overview — counts by status and total cost in addition to what's already shown.

### 5a. Compute dashboard stats
**File:** `lib/ui/vehicle/detail/view_models/vehicle_detail_viewmodel.dart`

The screen already builds a `JobListViewModel` for the recent-jobs summary. Reuse that — derive a `({int planned, int inProgress, int completed, double totalCost})` getter on `JobListViewModel` from its `_jobs` list. (Counts are needed across all jobs for the vehicle, not just the 3-item summary — the underlying list already holds them all.)

Listen to the job list's `fetchJobs` completion in the detail screen and rebuild the stats row.

### 5b. Stats row on the vehicle detail card
**File:** `lib/ui/vehicle/detail/widgets/vehicle_detail_screen.dart`

Insert a "Status" row between the existing info block and the "Recent Job History" header. Four tiles (Planned / In progress / Completed / Total cost). Tapping a status tile should push to `Routes.jobs(vehicleId)` with that status preselected — easy follow-up once #4c lands (router param or a method on `JobListViewModel`).

Use `IBMPlexMono` to match the rest of the detail screen's number formatting.

---

## Carry-overs (still open, not Phase 1 scope)

### Test coverage

`test/widget_test.dart` is still the Flutter counter placeholder. High-value targets (no Flutter dependencies, all business logic):

| Target | Scenarios |
|---|---|
| `Result<T>` (`lib/utils/result.dart`) | `Ok` / `Error` construction and exhaustive pattern matching |
| `Command<T>` (`lib/utils/command.dart`) | `running` flips, `error`/`completed` flags, `clearResult()` resets, second `execute()` while running is ignored |
| `HomeViewModel` | vehicles populated on fetch; list replaced (not appended) on re-fetch; error message set on failure |
| `JobListViewModel` | same — plus filter/sort behaviour once #4 lands |
| `VehicleFormViewmodel` / `JobFormViewModel` | add vs. update path chosen correctly based on whether the model is null |

Inject hand-rolled fakes implementing the repository interfaces — no `mockito` needed.

### Widget smoke tests (lower priority)
Basic render tests for `JobCard` (with/without photos, with/without `completionDate`), `HomeVehicleCard`, and the form screens to catch obvious build errors.
