# Muhurtham

A Flutter wedding planner with a soft dark-pink glass interface, rose and plum
gradients, frosted surfaces, and modern outlined service icons. The scalable
brand mark follows the ring, heart, and M motif in the supplied logo.

## Features

- Browse all 12 wedding services and their planning tips.
- Add venues or vendors to a local catalog, including city, address, services,
  capacity, indicative price, and optional coordinates.
- Filter listings by city, name, or locality.
- Tap **Use my location** to find coordinate-bearing local listings within
  25, 50, or 100 km, sorted by approximate straight-line distance.
- Save venue ideas, build a wedding checklist, and track completed details.
- Create dated booking requests for any service, using a catalog listing or a
  named provider. Validate event dates, guest counts, contact details, and venue
  capacity; prevent duplicate active requests.
- View and cancel requests in the Bookings tab.
- Restore listings, requests, shortlists, and checklist state on this device.

Booking requests are **saved locally and not sent to providers**. They do not
reserve a venue, confirm availability, or collect a payment. There is no booking
backend, provider notification, or cloud sync.

The original venue catalog remains clearly marked as sample data. Nearby search
excludes sample venues and listings without coordinates. It searches your local
catalog; it does not query Google Places or a live venue directory. Location is
requested only after a button tap. If access is denied, city browsing remains
available. Device location used for searching is kept in memory; coordinates
are saved only when explicitly included in an added listing.

## Development

Validated with **Flutter 3.47.5 / Dart 3.13.4**. Use this release to reproduce the
checked-in dependency lockfile.

```sh
flutter pub get --enforce-lockfile
flutter run -d chrome --no-web-resources-cdn
```

For a web server without a browser launcher:

```sh
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8766 --no-web-resources-cdn
```

Browser geolocation requires HTTPS or a trusted loopback origin. Android uses
foreground approximate location permission. Apple usage descriptions and
location entitlements are included; no background location feature is used.

The uploaded Android, iOS, desktop, and web projects are included. Native builds
require their platform SDKs; iOS/macOS require macOS. Android/iOS binaries have
not been validated in the cloud Linux environment.

## Checks

```sh
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
```

The 20 tests cover navigation, responsive layouts at 320/390/1280 pixels,
listing forms and persistence, city/radius filters, denied location access,
all service request types, duplicate prevention, date/capacity validation,
booking cancellation, saved venues, and checklist restoration.

The release web build bundles its renderer, icons, and Roboto fonts. It can
start without an external font or renderer CDN. The font license is included
in `assets/fonts/Roboto_LICENSE.txt`.

## Imported source

Imported from the supplied `muhurtham.rar`. The nested ZIP, caches, IDE files,
and machine-specific configuration were excluded. The original logo remains
at `assets/muhurtam.png`. Empty original artwork placeholders are retained;
the active interface uses scalable vector marks and built-in service icons.

Future cloud tasks should use the existing checkout. Do not create a Git
worktree unless explicitly requested.
