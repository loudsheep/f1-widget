# AGENTS.md

macOS app plus WidgetKit extension showing the next Formula 1 session. See `README.md` for the overview and `docs/CONCEPT.md` for the concept.

## Layout

- `F1Widget/`: SwiftUI app (calendar, results). Files are picked up automatically (synchronized folder group), so there is no need to edit the pbxproj when adding files.
- `F1WidgetExtension/`: widget (provider, intent, views). Same synchronized folder rule.
- `Packages/F1Core/`: local Swift package shared by both targets. All logic that can be tested without UI lives here.
- `Config/`: `Shared.xcconfig` (bundle ID prefix, deployment target), entitlements, widget Info.plist.
- `Scripts/generate_circuit_maps.py`: builds circuit SVGs from the f1-circuits repo.

## Running tests

Tests live in `Packages/F1Core/Tests/F1CoreTests` and use Swift Testing. There is no app or widget test target.

```
cd Packages/F1Core
swift test
```

Run a single test or suite:

```
swift test --filter CountdownTests
swift test --filter F1CoreTests.CountdownTests/formatsDaysHoursMinutes
```

Tests run offline. They decode recorded API responses: the season lives in `Sources/F1Core/Resources/SampleData/season.json` (it is also used by the widget preview gallery) and the results in `Tests/F1CoreTests/Fixtures/results.json`. When a new season starts, refresh them:

```
curl -s "https://api.jolpi.ca/ergast/f1/current.json?limit=100" -o Packages/F1Core/Sources/F1Core/Resources/SampleData/season.json
curl -s "https://api.jolpi.ca/ergast/f1/current/last/results.json" -o Packages/F1Core/Tests/F1CoreTests/Fixtures/results.json
```

Then update the expected counts in `F1CoreTests.swift` if the number of rounds changed.

`everyCircuitInFixtureHasAMap` fails when a circuit in the season fixture has no bundled SVG. Fix it by adding the circuit (see below), not by loosening the test.

## Building

Command line builds need signing disabled, because the team is only configured in Xcode:

```
xcodebuild -project F1Widget.xcodeproj -scheme F1Widget -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

Use a scratch `-derivedDataPath` to keep build output out of the repo.

A real run (widget visible on the desktop) needs a signed build from Xcode: set the team on both targets, then run the `F1Widget` scheme. After changing widget code, `killall F1WidgetExtension` forces the desktop widget to reload. Design iteration is fastest with the `#Preview` blocks in `F1WidgetExtension/NextRaceView.swift`.

## Adding a circuit

1. Add `<jolpica circuitId>: <f1-circuits id>` to `CIRCUIT_IDS` in `Scripts/generate_circuit_maps.py`.
2. Run `python3 Scripts/generate_circuit_maps.py <path-to-f1-circuits>`.
3. Run `swift test` in `Packages/F1Core`.

A missing circuit map is not an error at runtime. The widget falls back to the layout without a map.

## Adding a country

A new host country needs three things in `Packages/F1Core`: an ISO code in `CountryFlag.isoCodes`, a flag SVG in `Resources/Flags/<iso lowercase>.svg` (from flag-icons, 4x3), and a palette in `CountryTheme.palettes`. The first palette color drives the widget accent text and is lightened automatically to keep a 4.5 contrast ratio on black. `everyCountryInFixtureHasFlagAndTheme` fails until all three exist.

## Constraints

- The App Group ID `group.dev.loudsheep.f1widget` is duplicated in `Config/*.entitlements` and `AppGroup.identifier` in `DiskCache.swift`. Change all three together.
- The app and the widget both fetch through `F1Repository` and share a disk cache in the App Group container. The widget must not depend on the app running.
- Deployment target is macOS 27.0 (`Config/Shared.xcconfig` and `Package.swift`).

## Conventions

- Commit messages use conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, with an optional scope, for example `fix(widget): advance countdown at session start`.
- Do not commit unless asked. Never add the agent as a co-author.
- Keep code comments to a minimum. Prefer clear names.
- Use a plain dash "-", never an em dash.
