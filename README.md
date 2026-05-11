# Scoundrel PWA

Scoundrel is a solo dungeon-crawl card game packaged as a Vite-powered progressive web app. The game is intended to install and work offline from its public production Vercel aliases.

## Local Development

Install dependencies and run the app:

```sh
npm install
npm run dev
```

To verify the production PWA build locally:

```sh
npm run build
npm run preview
```

## PWA Notes

The app manifest, service worker, icons, and screenshots are committed in the repo and are expected to work on the public production site.

- Manifest: `public/manifest.webmanifest`
- Service worker: `public/sw.js`
- Install icons: `public/icons/`
- Install screenshots: `public/screenshots/`

## Vercel Installability

Use only the public production aliases when checking PWA installability in browser DevTools:

- `https://scoundrel-game-pwa-lilac.vercel.app`
- `https://scoundrel-game-pwa-gustav-devhubs-projects.vercel.app`

These are the authoritative browser-facing install URLs for this project.

### Expected Protected URLs

The following Vercel hostnames may be protected and are not valid installability test targets:

- hashed deployment URLs such as `https://scoundrel-game-pa968bsc3-gustav-devhubs-projects.vercel.app`
- branch aliases such as `https://scoundrel-game-pwa-git-main-gustav-devhubs-projects.vercel.app`

When those protected URLs are used, `manifest.webmanifest` can return a Vercel Authentication page instead of manifest JSON. Chrome DevTools then reports false installability failures because it is parsing the auth HTML, not the real manifest.

Typical false-negative symptoms include:

- invalid `start_url`
- missing `name` or `short_name`
- invalid `display`
- missing icons
- general installability errors in `Application > Manifest`

This is expected behavior for protected deployment URLs and is not a PWA bug if the public production alias works.

## Vercel Troubleshooting

If you see `401`, `403`, or a Vercel Authentication page for `/manifest.webmanifest`:

1. Confirm you are testing a public production alias, not a protected deployment URL.
2. Check the hostname carefully. The production alias is `lilac`, not `iliac`.
3. Re-test from the public alias in DevTools `Application > Manifest`.

If the public production alias returns manifest JSON and the app installs correctly there, the deployment is considered healthy even if the Vercel dashboard preview or protected URLs show `Forbidden`.

## Verification Checklist

- Open the public production alias.
- Confirm `/manifest.webmanifest` returns JSON.
- Open DevTools `Application > Manifest`.
- Confirm icons and screenshots resolve.
- Confirm installability warnings are gone on the public alias.
- Test offline mode only after the public alias has loaded successfully at least once.
