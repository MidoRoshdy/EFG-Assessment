# Currency Converter

A Flutter currency converter built for the EFG Holding Mid-Level Flutter Engineer assessment.
It fetches live exchange rates from the [Frankfurter API](https://frankfurter.dev), converts between currencies through a validated form, and keeps a persistent history of every conversion on the device. It also works offline using the last cached rates.

## Features

**Required**

- **Converter screen**: enter an amount, pick a base and a target currency, and submit. The form is validated: the amount is required, must be a number and must be greater than 0, and input is limited to digits with up to 4 decimals.
- **Searchable currency picker**: a bottom sheet that filters by code or name, e.g. `usd` or `dollar`.
- **Live rates** from Frankfurter, with visible loading and error states. While a request runs, the spinner appears in the Convert button and the inputs are locked.
- **Conversion details**: amount, converted amount, exchange rate, inverse rate, rate date and source (Live or Cached).
- **History screen**: every completed conversion is saved to a local SQLite database and survives app restarts. It uses a reusable list component, and tapping an entry opens a details page.
- **Centralised design system** (colour palette, typography scale, spacing values) and a small reusable widget library.
- **Responsive layout**: content is centred and width-capped, so it reads well on both phones and tablets.

**Optional (all implemented)**

- **Offline fallback using the last cached rates**. Results are clearly marked with an offline banner and a "Cached (offline)" source, both on the converter and in history.
- **Dark mode**: System, Light or Dark, chosen in Settings and saved.
- **Delete individual history entries**: swipe to delete, or use the delete button on the details page, which asks for confirmation.
- **Unit and widget tests**: 84 tests covering about 94% of the code.

**Extra**

- **Settings screen** with default "from" and "to" currencies that are applied on launch, and live while the app is running.
- A swap-currencies button.

---

## Setup instructions

### Requirements

| Tool | Version used |
|---|---|
| Flutter | 3.35.x (stable channel) |
| Dart | 3.9.x |
| Xcode + CocoaPods | For iOS only (CocoaPods 1.16+) |
| Android Studio / Android SDK | For Android only |

No API key is needed, because Frankfurter is free and doesn't use keys. That means there are no secrets to configure.

### Run

```bash
git clone https://github.com/MidoRoshdy/EFG-Assessment.git
cd EFG-Assessment
flutter pub get
flutter run
```

On iOS, `flutter run` installs the pods automatically. If CocoaPods isn't found, install the pods manually with `cd ios && pod install`.

### Tests

```bash
flutter test               # run all tests
flutter test --coverage    # write a coverage report to coverage/lcov.info
flutter analyze            # static analysis (lints)
```

The tests need no device or network. The database tests use an in-memory SQLite database via `sqflite_common_ffi`.

### Troubleshooting

| Problem | Fix |
|---|---|
| `MissingPluginException` after pulling | You added a package that has native code, and hot reload doesn't include it. Stop the app completely and run `flutter run` again. |
| `CocoaPods not installed` when launching from the IDE, even though `pod` works in a terminal | The IDE didn't inherit your shell's `PATH`. Restart the IDE from a terminal, or add Homebrew's path (`/opt/homebrew/bin`) to the Dart extension setting `dart.env`. |

---

## Architectural decisions

### Clean Architecture, organised by feature

The code is grouped by feature first, and each feature is split into three layers. Dependencies only point inward: presentation depends on domain, and data depends on domain.

```
lib/
├── main.dart                   # opens SharedPreferences and SQLite, then runApp with ProviderScope
├── app.dart                    # MaterialApp: theme + dark theme + themeMode from settings
├── core/                       # shared by all features, no feature logic
│   ├── constants/              # API URLs and timeouts
│   ├── error/                  # exceptions (data layer) and failures (domain layer)
│   ├── network/                # ApiClient (http wrapper) and its providers
│   ├── storage/                # AppDatabase (SQLite schema and upgrades), SharedPreferences provider
│   ├── theme/                  # design system: colours, typography, spacing, ThemeData
│   ├── utils/                  # DateFormatter
│   └── widgets/                # reusable widget library
└── features/
    ├── converter/
    │   ├── data/               # remote and local data sources, models, repository implementation
    │   ├── domain/             # entities, repository interface, use cases
    │   └── presentation/       # page, widgets, Riverpod providers and notifier
    ├── history/                # same three layers
    ├── settings/               # same three layers
    └── home/                   # bottom-navigation shell
```

| Layer | Responsibility | Depends on |
|---|---|---|
| **Domain** | Plain Dart entities (`ConversionResult`, `ConversionRecord`, `AppSettings`), abstract repository interfaces, and use cases (`ConvertCurrency`, `GetCurrencies`, `GetHistory`, `SaveConversion`, `DeleteConversion`). No Flutter imports. | Nothing |
| **Data** | Data sources (HTTP, SQLite, SharedPreferences), models that convert to and from JSON or database rows, and repository implementations that turn low-level exceptions into domain `Failure`s. | Domain |
| **Presentation** | Pages and widgets, Riverpod notifiers and providers. Widgets never call data sources directly. | Domain (and data only for dependency wiring) |

### State management: Riverpod 3

The brief accepted Riverpod alongside BLoC. I chose Riverpod because:

- **It doubles as dependency injection.** Every data source, repository and use case is a `Provider`, so there's no separate service locator. The graph for one feature looks like this:
  `apiClientProvider → converterRemoteDataSourceProvider → converterRepositoryProvider → convertCurrencyProvider → converterProvider`
- **It makes testing easy.** A test swaps a whole layer with one line, for example `converterRepositoryProvider.overrideWithValue(FakeConverterRepository())`. No mocking framework is needed.
- **Its `AsyncValue` type** holds loading, data and error, which maps directly onto the loading and error states the brief requires.

State holders:

| Provider | Type | Holds |
|---|---|---|
| `currenciesProvider` | `FutureProvider` | The currency list, with loading, error and retry. |
| `converterProvider` | `Notifier<ConverterState>` | The selected currencies and the result as `AsyncValue<ConversionResult?>`. |
| `historyProvider` | `AsyncNotifier<List<ConversionRecord>>` | The history list. Adding and deleting update it straight away, and a failed delete is rolled back. |
| `settingsProvider` | `Notifier<AppSettings>` | Theme and default currencies, saved to SharedPreferences. |
| `homeTabProvider` | `Notifier<HomeTab>` | The selected bottom-navigation tab. |

Some behaviour worth pointing out:

- **Late responses are ignored.** If the user changes a currency while a request is in flight, the old response is discarded rather than overwriting the new state.
- **Settings apply live.** The converter uses `ref.listen` on the default-currency settings, so changes in Settings take effect without restarting.
- **Saving history never breaks a conversion.** If the database write fails, the result is still shown to the user.

### Error handling

The data layer throws `ServerException`, `NetworkException` or `CacheException`. Repositories convert these into a sealed `Failure` type: `ServerFailure`, `NetworkFailure` or `CacheFailure`. The presentation layer only ever sees `Failure`s, and shows their message in a consistent error component.

### Storage

| Data | Storage | Why |
|---|---|---|
| Conversion history | **SQLite** (`sqflite`) | Structured records that need ordering and deleting by id, and that may grow over time. A real database suits this better than a key-value store. |
| Cached rates and currencies | **SQLite** | Kept alongside history, so the app has a single database. |
| Settings | **SharedPreferences** | A handful of small values, read synchronously on startup so the saved theme applies before the first frame. |

The database schema is versioned in `AppDatabase`, with upgrades from version 1 to 3: version 2 added the cache tables and version 3 added `is_cached` to history. A test verifies that a version 1 database upgrades without losing any data.

### Offline strategy

1. When online, every conversion fetches **all** rates for the base currency (`/latest?from=USD`) and caches that table in `rates_cache`. The currency list is cached too.
2. On a `NetworkException` (no connection or a timeout), the repository falls back to the cache. It tries the table for the same base currency first, then works out a **cross rate** from any other cached table. For example, EUR→EGP can be derived from a cached USD table as `USD→EGP ÷ USD→EUR`.
3. Server errors, such as an invalid currency pair, are **not** hidden behind cached data. They're shown to the user.
4. Cached results carry `isCached = true`. That flag drives the offline banner and the "Source" row, and it's stored with the history entry.
5. Separately, `isOnlineProvider` (built on `connectivity_plus`) watches the device's network state. While the device is offline, a banner at the top of every tab warns that rates may be outdated and that the last saved rates are being used, not the most recent ones. It reports interface state only, so Wi-Fi without internet still reads as online; in that case step 2 still catches the failed request.

### Package choices

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management and dependency injection. |
| `http` | A small HTTP client, wrapped by `ApiClient`, which adds timeouts, error mapping and JSON decoding. |
| `sqflite`, `path` | The local SQLite database. |
| `shared_preferences` | Settings. |
| `connectivity_plus` | Watches network state for the top offline banner. |
| `sqflite_common_ffi` (dev only) | Lets the database tests run against real SQLite inside `flutter test`. |

I deliberately left out code generation (freezed, riverpod_generator), `dartz` and `intl` to keep the project small and easy to follow. The brief says "a clean, well-structured app outweighs a feature-rich one".

---

## Design system approach

All visual decisions live in `lib/core/theme/`, and screens take them from `Theme.of(context)` and the spacing values instead of hard-coding anything.

| File | Contents |
|---|---|
| `app_colors.dart` | Brand palette (primary `#0B3D91`, secondary `#00A6A6`, error, success) plus background, surface and text colours for light and dark themes. |
| `app_typography.dart` | A single `TextTheme` scale from `displaySmall` (36) down to `bodySmall` (12). |
| `app_spacing.dart` | Spacing values on a 4-point grid (`xxs` 2, `xs` 4, `sm` 8, `md` 16, `lg` 24, `xl` 32, `xxl` 48) and corner radii (`radiusSm`, `radiusMd`, `radiusLg`). |
| `app_theme.dart` | Builds Material 3 `ThemeData` for light and dark from one shared builder, with consistent input fields, buttons and cards. |

**Dark mode** comes from the same builder with a dark `ColorScheme`. Widgets use colour roles such as `primaryContainer`, `errorContainer` and `tertiaryContainer` rather than fixed colours, so every screen adapts automatically.

**Reusable widget library** (`lib/core/widgets/`), used across all screens:

| Widget | Used by |
|---|---|
| `AppPrimaryButton` | The Convert button. Its built-in loading state disables it and shows a spinner. |
| `AppListItem` | The shared list row. History entries are built on it through `HistoryListItem`. |
| `AppDetailsCard` / `AppDetailItem` | The label/value box, shared by the converter result and the history details page so they look identical. |
| `AppErrorView` | Full-screen errors with an optional Retry button. |
| `AppEmptyView` | Empty states, such as an empty history. |
| `AppLoadingView` | Full-screen loading. |

**Responsive layout:** content is wrapped in a `ConstrainedBox` with a maximum width (560 for forms and details, 720 for lists) and centred. On tablets it stays readable instead of stretching edge to edge, and on phones it fills the width.

---

## Testing

84 tests covering about 94% of the code, organised to mirror `lib/`:

```
test/
├── helpers/                    # fakes (converter and history repositories) and pumpApp / createTestContainer
├── core/                       # ApiClient (with a mock HTTP client), AppDatabase schema and upgrades, DateFormatter, shared widgets
└── features/
    ├── converter/              # models, local cache (real SQLite), remote data source, repository offline fallback,
    │                           # use case, notifier (stale responses, saving to history), converter page widgets
    ├── history/                # model, SQLite data source, repository error mapping, notifier (rollback), history page widgets
    └── settings/               # repository defaults and saved values, notifier, settings page widgets
```

- **Unit tests** cover the models, use cases, repositories (including every offline fallback path) and notifiers, running in a Riverpod `ProviderContainer`.
- **Database tests** run against a real in-memory SQLite database, including the version 1 → 3 upgrade.
- **Widget tests** cover each screen from start to finish: validation, the loading state locking the inputs, the offline banner, retry after an error, currency search, the history details page, swipe and confirm deletion, and dark mode being saved.

---

## AI usage note

**Tools:** Cursor's AI agent, used inside the Cursor editor.

**What I used it for:**

- Scaffolding the Clean Architecture folder structure and the Riverpod setup.
- Building features step by step from my own prompts: the converter form, the searchable picker, settings and dark mode, SQLite history, offline caching, and the test suite.
- Diagnosing environment problems: a `MissingPluginException` that needed a full rebuild, and CocoaPods not being on the IDE's `PATH`.
- Drafting this README.

**How I checked the output:**

- I directed the work one feature at a time and reviewed each change before moving on. I asked for changes when the behaviour wasn't what I wanted, for example keeping the loading spinner only in the button, and applying default currencies live instead of only after a restart.
- `flutter analyze` returns no issues, and all 84 tests pass after every change.
- I checked the API's real responses with `curl`. That's how I found that `frankfurter.app` now redirects to `api.frankfurter.dev/v1`, and that converting a currency to itself returns HTTP 422, which the app now handles locally.
- I ran the app on the iOS Simulator and tried each flow by hand: converting, searching currencies, theme switching, history and deletion, and the offline fallback with networking turned off.
