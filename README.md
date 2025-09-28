# shoplite
A compact Flutter e-commerce app built for the ShopLite hiring task.

1. Problem Statement

Build ShopLite, a 3-screen shopping app:
Catalog: Paginated product list with search and category filters.
Product Detail: Images carousel, price, description, rating, add/remove favorites, and add to cart.
Cart/Checkout (mock): View items, update quantity, remove items, and a mock “Place Order” flow with summary.
Authentication is email + password (mock) with a token stored securely. Favorites and cart must persist across app restarts. The app should work with spotty/no internet by reading from a local cache.

2. Data Source (choose ONE)

Pick whichever you prefer (no keys needed):
DummyJSON (products, categories, auth): https://dummyjson.com/
Products: /products?limit=20&skip=0
Product by id: /products/{id}
Categories: /products/categories
Search: /products/search?q={query}
Login: POST /auth/login (returns token), GET /auth/me (verify)
Fake Store API (products, categories, auth): https://fakestoreapi.com/
If you’d rather avoid external APIs, you may serve the same shapes locally via json-server. Just note it clearly in your README.
3. Core Requirements (must-have)

A. Architecture & State

Use a layered architecture (data/domain/presentation) with Repository pattern.
Choose one state management approach (BLoC, Riverpod, or ValueNotifier + InheritedWidget).
Explain the choice in the README.
B. Networking & Caching
Paginated catalog (infinite scroll or “Load more”).
Search by keyword and filter by category.
Offline-first: cache the latest catalog & product detail to local storage (Hive / Isar / SQLite).
If network fails, show cached data with an offline banner.
Cache should have a simple stale strategy (e.g., 30 min TTL or version bump).
C. Auth (Mock)
Login screen (basic validation).
On success, store token in secure storage.
Gate the Cart behind auth: unauthenticated users get redirected to login.
D. Favorites & Cart
Mark/unmark favorite (local persistence).
Cart: add/remove items, modify quantity, compute totals, and mock “Place Order.”
Show a toast/snackbar confirmation on add/remove.
E. UX & UI
Light/Dark theme toggle.
Pull-to-refresh on catalog.
Hero animation or equivalent micro-interaction from list → detail.
Empty/error/loading states that look intentional (not just a spinner).
F. Quality
Static analysis: flutter analyze must pass; enable flutter_lints (or equivalent).
Unit tests: at least 4 (repositories/services + 1 viewmodel/cubit/bloc).
Widget test: at least 1 (e.g., catalog list + empty/error state).
CI: GitHub Actions that runs formatting, analyze, and tests.
Performance: avoid unnecessary rebuilds; lazy image loading.

4. Nice-to-Have (stretch, time permitting)

Localization: English + Hindi (2–3 strings).
Golden tests for a small widget.
Deep links to open a product detail.
Simple dependency injection (get_it or Riverpod providers).
Accessibility: semantic labels on tappables & images.
Stretch items are bonus; don’t sacrifice core quality to add them.

5. Deliverables

GitHub repository (public or share access):
Code organized by layers.
A README.md covering:
App overview & screenshots
Architecture diagram (ASCII, Mermaid, or image)
State management choice & why
How to run (Android & iOS/simulator)
How to run tests
Caching strategy & offline behavior
Known trade-offs / limitations
CI status badge in README (if using GitHub).
Build artifacts
Android APK under builds/ShopLite.apk (or attach via release).
(Optional) iOS: instructions to run on Simulator.
App demo video (3–6 min)
Unlisted link (Loom/Drive/YouTube) or MP4 in demo/.
Must show: login, paginated catalog, search & category filter, detail with images, favorites, add to cart, update qty, offline banner with cached list, mock checkout success.
Test coverage summary (a line in README or screenshot of terminal).

6. Acceptance Criteria

App builds and runs on Android emulator/device.
Catalog loads with pagination; search & category filter both work.
Product detail displays images, title, price, description, and rating.
Favorites persist across restarts.
Cart: add/remove/update; total updates correctly; “Place Order” shows success screen.
Login protects cart flow; token stored securely; logout clears sensitive state.
Killing network still shows last cached catalog with an offline indicator.
Code passes flutter analyze and tests pass on CI.
README is clear; demo video covers required flows.

7. Technical Constraints

Flutter stable (3.x+) with sound null-safety.
Use Dio or http, plus a JSON serializer (json_serializable or manual).
Use CachedNetworkImage (or similar) for product images.
Local storage: Hive, Isar, or sqflite.
Avoid heavy packages unless justified in README.

8. Demo Script (what to show in your video)

Launch → Login (show validation, then success).
Catalog loads → scroll to trigger pagination.
Use Search (type a keyword) and Category filter.
Tap product → Hero image animation → detail; add/remove Favorite.
Add to Cart → go to Cart → change quantities → see totals update.
Turn airplane mode on → return to Catalog → see cached items + offline banner.
Mock “Place Order” → success screen.
Relaunch app → favorites & cart still present.
