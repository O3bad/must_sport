# Font License and Delivery Notes

The app uses the typefaces listed below under the **SIL Open Font License,
Version 1.1** (OFL-1.1). The currently active families are fetched at runtime
through the `google_fonts` package; their font requests disclose the user's IP
address and request metadata to Google. These fonts are not bundled in the
Flutter font manifest.

## Fonts used by the app

| Family | Copyright holder | License | Delivery |
|---|---|---|---|
| Inter | Copyright 2016 The Inter Project Authors | OFL-1.1 | Google Fonts at runtime |
| Plus Jakarta Sans | Copyright 2020 The Plus Jakarta Sans Project Authors | OFL-1.1 | Google Fonts at runtime |
| Noto Kufi Arabic | Copyright 2021 The Noto Project Authors | OFL-1.1 | Google Fonts at runtime |

## Font files present in this repository

The Cairo, Noto Sans Arabic and Poppins font files and OFL texts are present
under this directory, but `pubspec.yaml` does not declare those font files as
Flutter assets or font families. They are therefore not treated as fonts
shipped by the current app build. Their OFL texts are included in the app's
asset list.

## Other third-party assets

The rights and provenance for the app icon and splash artwork are **not
established by this font audit** and must be confirmed by the project owner
before redistribution. The sample `assets/users_cache.json` file is no longer
bundled or loaded by the app.

## Attribution

The app displays font attribution under **Settings → Open Source Licenses**.
Confirm attribution and asset provenance against the exact font files delivered
in each release. OFL-1.1 requires that fonts are not sold on their own and that
reserved font names are not reused for modified versions.

Full license text: <https://openfontlicense.org>
