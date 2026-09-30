# Muhurtham

A Flutter wedding planning app with a light pink glass interface, soft rose and
lavender gradients, frosted cards, and rounded service icons.

## What works

- Browse 12 wedding services and open their planning tips.
- Search the sample venue catalog by venue name or city.
- Save venues to a shortlist using the heart icons.
- Add services to a wedding checklist, mark them complete, and remove them.
- Keep the shortlist and checklist on the device using local preferences.
- Use responsive layouts on phones and larger screens.

The venue data comes from the uploaded app's sample catalog. Prices are
illustrative. Vendor accounts, availability, bookings, payments, and cloud sync
are not connected to a backend.

## Development

Validated with **Flutter 3.47.5 / Dart 3.13.4**. Use Flutter 3.47.5 to reproduce
the checked-in dependency lockfile.

```sh
flutter pub get --enforce-lockfile
flutter run -d chrome
```

For a web server without a browser launcher:

```sh
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8765 --no-web-resources-cdn
```

The repository includes the uploaded Android, iOS, desktop, and web projects.
Native builds require the corresponding platform SDKs; iOS/macOS require macOS.
Android and iOS binaries have not been validated in the cloud Linux environment.

## Checks and web build

```sh
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
```

The seven widget tests cover splash navigation, search and empty results, saved
venues, persistent checklist state, and layouts at 320, 390, and 1280 pixels.
The web build bundles its renderer, icons, and Roboto fonts so startup does not
depend on an external font or renderer CDN. The font license is included in
`assets/fonts/Roboto_LICENSE.txt`.

## Imported source

Imported from the supplied `muhurtham.rar`. The nested ZIP, dependency caches,
IDE files, and machine-specific configuration were excluded. The original
logo remains at `assets/muhurtam.png`. Many other original artwork files are
empty placeholders; the updated screens use built-in vector icons instead.

Future cloud tasks should use the existing checkout. Do not create a Git
worktree unless explicitly requested.
