# Backlog

Open items from the initial code review. The crash-level bugs and most design issues were fixed in commit `1383e1a`; what remains is below.

---

## 1. Token expiry UX — silent logout

**File:** `lib/data/repositories/auth/auth_repository_remote.dart`

When `isAuthenticated` detects an expired JWT it calls `logout()` internally and returns `false`, which causes the GoRouter redirect to bounce the user to `/login` with no explanation.

**What to do:**
- Surface a "Your session has expired, please log in again" message before redirecting. One approach: add an `authError` stream or `String? sessionMessage` field to `AuthRepository` that the login screen reads on arrival.
- Longer term: if the backend supports refresh tokens, add a `refreshToken` call in `isAuthenticated` before falling back to logout.

---

## 2. Test coverage — currently zero

**File:** `test/widget_test.dart` (placeholder only — tests the default Flutter counter app, not this codebase)

The highest-value targets are the utility classes and ViewModels since they hold all business logic and have no Flutter dependencies:

### 2a. `Result<T>` and `Command<T>` unit tests
`lib/utils/result.dart`, `lib/utils/command.dart`

- `Result.ok` / `Result.error` construction and pattern matching
- `Command0` / `Command1`: running state flips correctly, error/completed flags set after execution, `clearResult()` resets state, a second `execute()` while running is ignored

### 2b. ViewModel unit tests

Each ViewModel can be tested by injecting a fake repository (implement the abstract interface with a simple in-memory stub — no mocking library needed).

| ViewModel | Key scenarios to cover |
|-----------|------------------------|
| `HomeViewModel` | vehicles populated after fetch; list replaced (not appended) on re-fetch; error message set on failure |
| `JobListViewModel` | same as above for jobs |
| `LoginViewModel` | `login` command delegates to repository; error propagated |
| `RegisterViewModel` | same |
| `VehicleFormViewmodel` | add vs. update path chosen correctly based on whether `vehicle` is null |
| `JobFormViewModel` | same |

### 2c. Widget smoke tests (lower priority)
Basic render tests for `JobCard` (with and without `completionDate`), `HomeVehicleCard`, and form screens to catch obvious build errors.

**Suggested setup:** add `mockito` or hand-roll simple fakes — the repository interfaces are small and straightforward to stub.
