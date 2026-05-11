const APP_CACHE = 'scoundrel-app-v2'
const RUNTIME_CACHE = 'scoundrel-runtime-v2'

const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.webmanifest',
  '/assets/index.css',
  '/assets/index.js',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/screenshots/scoundrel-mobile.png',
  '/screenshots/scoundrel-desktop.png',
  '/scoundrel/index.html',
  '/scoundrel/style.css',
  '/scoundrel/js/achievements.js',
  '/scoundrel/js/audio.js',
  '/scoundrel/js/leaderboard.js',
  '/scoundrel/js/main.js',
  '/scoundrel/js/particles.js',
  '/scoundrel/assets/favicon.png',
  '/scoundrel/assets/images.jpg/club-1.jpg',
  '/scoundrel/assets/images.jpg/club-2.jpg',
  '/scoundrel/assets/images.jpg/club-3.jpg',
  '/scoundrel/assets/images.jpg/deck.jpg',
  '/scoundrel/assets/images.jpg/diamond-1.jpg',
  '/scoundrel/assets/images.jpg/diamond-2.jpg',
  '/scoundrel/assets/images.jpg/diamond-3.jpg',
  '/scoundrel/assets/images.jpg/heart.jpg',
  '/scoundrel/assets/images.jpg/spade-1.png',
  '/scoundrel/assets/images.jpg/spade-2.jpg',
  '/scoundrel/assets/images.jpg/spade-3.jpg'
]

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(APP_CACHE).then((cache) => cache.addAll(PRECACHE_URLS)).then(() => self.skipWaiting()),
  )
})

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== APP_CACHE && key !== RUNTIME_CACHE)
          .map((key) => caches.delete(key)),
      ),
    ).then(() => self.clients.claim()),
  )
})

self.addEventListener('fetch', (event) => {
  const { request } = event

  if (request.method !== 'GET') {
    return
  }

  const url = new URL(request.url)

  if (url.origin !== self.location.origin) {
    return
  }

  if (request.mode === 'navigate') {
    event.respondWith(handleNavigation(request))
    return
  }

  event.respondWith(cacheFirst(request))
})

async function handleNavigation(request) {
  try {
    const networkResponse = await fetch(request)
    const runtimeCache = await caches.open(RUNTIME_CACHE)
    runtimeCache.put(request, networkResponse.clone())
    return networkResponse
  } catch {
    const cachedResponse = await caches.match(request)
    if (cachedResponse) {
      return cachedResponse
    }

    return (await caches.match('/index.html')) || Response.error()
  }
}

async function cacheFirst(request) {
  const cachedResponse = await caches.match(request)
  if (cachedResponse) {
    return cachedResponse
  }

  try {
    const networkResponse = await fetch(request)

    if (networkResponse && networkResponse.ok) {
      const runtimeCache = await caches.open(RUNTIME_CACHE)
      runtimeCache.put(request, networkResponse.clone())
    }

    return networkResponse
  } catch {
    if (request.destination === 'document') {
      return (await caches.match('/index.html')) || Response.error()
    }

    return Response.error()
  }
}
