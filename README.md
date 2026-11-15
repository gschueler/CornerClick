# CornerClick

Turn the four corners of your screen into buttons that never move.

CornerClick puts an invisible hot area in each screen corner. Click it, right-click it, or rest
the pointer there to open apps, files and URLs, hide apps, show Mission Control, lock the screen,
run Shortcuts or AppleScripts, and more. Hold modifier keys (fn ⌃ ⌥ ⇧ ⌘) to give each corner as
many actions as you like.

Fitts's law makes the corners the easiest targets on the screen to hit: throw the pointer at one
and it stops exactly there.

This is CornerClick 1.0, a native rewrite for Apple silicon and macOS 14 and later. It's built and
tested on macOS 27. The original 0.9 preference pane (2003–2010, by Greg Schueler) is kept in
[`legacy/`](legacy/).

## Features

- **Per-corner action lists** with Click, Right-Click (or ⌃-Click), Hover and Delayed Hover triggers
- **Modifier keys** select different actions on the same corner
- **Combos**: actions with the same trigger and modifiers run together, top to bottom
- **Action list HUD** (Liquid Glass on macOS 26+) shows what each corner does as you point at it.
  Scroll to pick an entry, then click to run it.
- **Multiple displays**: one shared set of corners, or separate corners for each display
- **Actions**: Open app/file/folder, Open URL, Hide current app, Hide other apps, Mission Control,
  App Exposé, Show Desktop, Show Apps, Start screen saver, Put displays to sleep, Lock screen,
  Run Shortcut, Run AppleScript
- Menu bar extra, Open at Login, and a warning when a macOS Hot Corner competes with the same corner
- **Imports CornerClick 0.9 settings** from this Mac or from a `us.vario.greg.CornerClick.plist` file
- No Accessibility or Screen Recording permission needed

## Install

Download `CornerClick.zip` from the latest
[release](https://github.com/B-E-N-D-E-R/CornerClick-1.0/releases), unzip it, and move
**CornerClick.app** to Applications. Or build it yourself:

```bash
git clone https://github.com/B-E-N-D-E-R/CornerClick-1.0.git
cd CornerClick-1.0
./build.sh --install
```

The build needs only the Xcode Command Line Tools (`xcode-select --install`). Full Xcode isn't
required.

| Option | Effect |
| --- | --- |
| `./build.sh` | Builds `build/CornerClick.app` (arm64) |
| `./build.sh --universal` | arm64 + x86_64 |
| `./build.sh --install` | Also installs to /Applications and launches |
| `SIGN_IDENTITY="Developer ID Application: …" ./build.sh` | Signs with your identity and the hardened runtime |

Local builds are ad-hoc signed. If you download a release that isn't notarized, right-click the app
and choose **Open** the first time.

## Tips

- Turn off macOS **Hot Corners** (System Settings › Desktop & Dock › Hot Corners…) on corners you
  use with CornerClick. Otherwise both fire.
- If you hide the menu bar icon, open CornerClick from Applications again to get to Settings.
- AppleScripts that control other apps trigger a one-time macOS permission prompt per app.
- Dashboard actions from 0.9 are skipped on import because Dashboard no longer exists.

## Developing

Sources live in `Sources/`:

| File | Contents |
| --- | --- |
| `Model.swift` | Corners, triggers, modifiers, actions, settings |
| `Store.swift` | Persistence and CornerClick 0.9 import |
| `CornerEngine.swift` | Corner panels, hover/click/scroll handling |
| `HUD.swift` | The floating action list and error banner |
| `ActionRunner.swift` | Performs actions |
| `SettingsView.swift` | SwiftUI Settings (Corners, General, About) |
| `main.swift` | App lifecycle, menu bar extra, Settings window |
| `SelfTest.swift` | `CC_SELFTEST=<dir>` drives the UI headlessly and writes screenshots |

Engine logs: `log stream --level info --predicate 'subsystem == "io.github.cornerclick.CornerClick"'`

## License

Apache License 2.0. Copyright 2003–2010 Greg Schueler, 2026 contributors. See [LICENSE](LICENSE).
