# f1-widget

An open source macOS app and widget for Formula 1. It shows the next session, a countdown, session times, a track outline, and the flag of the host country. The app adds the full season calendar and race results.

Data comes from [Jolpica F1](https://api.jolpi.ca/ergast/), the successor to the Ergast API.

## Features

- **Widget (small):** flag or track outline style, race name, and "Next in: X h, Y min". The style is chosen under Edit Widget.
- **Widget (medium):** track outline, race name, all session times, countdown, and flag.
- **App:** season calendar and results for completed races.

## Requirements

- macOS 27 or later
- Xcode 27 or later
- An Apple ID added to Xcode (a free personal team is enough)

## Building

1. Open `F1Widget.xcodeproj`.
2. For both the `F1Widget` and `F1WidgetExtension` targets, set your team under Signing & Capabilities.
3. Run the `F1Widget` scheme.
4. Right-click the desktop, choose Edit Widgets, and add "Next Race".

The bundle ID prefix and App Group are set in `Config/Shared.xcconfig` and `Config/*.entitlements`. If you fork this, change them to your own and update `AppGroup.identifier` in `Packages/F1Core/Sources/F1Core/DiskCache.swift`.

## Project layout

| Path | Purpose |
|:---|:---|
| `F1Widget/` | The macOS app |
| `F1WidgetExtension/` | The WidgetKit extension |
| `Packages/F1Core/` | Shared models, API client, cache, countdown, flags, circuit maps |
| `Config/` | xcconfig, entitlements, widget Info.plist |
| `Scripts/` | Circuit map generator |

## Circuit maps

Outlines are generated from [f1-circuits](https://github.com/bacinger/f1-circuits) GeoJSON:

```
python3 Scripts/generate_circuit_maps.py <path-to-f1-circuits>
```

See `AGENTS.md` for adding a new circuit.

## License

MIT, see `LICENSE`. Third party notices are in `THIRD_PARTY_NOTICES.md`.
