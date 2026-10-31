# Tribe Green — Admin Portal Handover

> **Project:** Tribe Green Admin Portal  
> **Platform:** Flutter Web  
> **Backend:** Supabase  
> **Recorded effort:** 7 hours

---

## 1. Project overview

A responsive Flutter admin dashboard for managing the Tribe Green corporate-gifting catalogue and customer enquiries.

## 2. Run the project

### Prerequisites

- Flutter stable with Dart SDK `3.13.4` or later.
- Chrome for local web development.
- A configured Supabase project.

### Environment setup

Create the local environment file:

```bash
cp keys.env.example keys.env
```

Set the values in `keys.env`:

```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

The app currently reads `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. `SUPABASE_ANON_KEY` is present in the example file but is not currently read by the app.

### Install, run and build

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=keys.env
```

Run tests:

```bash
flutter test
```

Build the production web app:

```bash
flutter build web --release --dart-define-from-file=keys.env
```

For hosting under a subpath, add the appropriate `--base-href`, for example `--base-href /gifting_admin/`.

**Backend setup:** The app expects Supabase `products`, `enquiries`, and `user_roles` tables, appropriate RLS policies, and the `get_enquiry_stats` RPC. SQL migrations and schema setup scripts were not included in the supplied archive. Obtain and apply the backend schema before running against a new Supabase project.

**Security:** Never put a Supabase service-role key in the Flutter app. Use the publishable/anon key and enforce access through RLS. Keep `keys.env` private and out of version control.

---

## 3. Source control and deployment

### Git / GitHub

Use Git for source control and GitHub as the remote repository.

```bash
git init
git add .
git commit -m "Initial Tribe Green admin portal"
git branch -M main
git remote add origin https://github.com/YOUR_ORG/YOUR_REPOSITORY.git
git push -u origin main
```

Before committing, make sure secrets and generated files are excluded. Add these entries to `.gitignore` if they are not already present:

```gitignore
keys.env
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
build/
coverage/
.idea/
.vscode/
.DS_Store
```

Commit `keys.env.example` with placeholder values, but never commit `keys.env`, Supabase service-role keys, Firebase service-account files, or other credentials.

### Deploy Flutter Web to GitHub Pages

Build the web app with the correct GitHub Pages base path. For a repository named `YOUR_REPOSITORY`, the base path is normally `/<YOUR_REPOSITORY>/`:

```bash
flutter pub get
flutter build web --release \\
  --base-href /YOUR_REPOSITORY/ \\
  --dart-define-from-file=keys.env
```

Publish the contents of `build/web/` to the GitHub Pages deployment source. This can be done with a GitHub Actions workflow or by configuring Pages to use a deployment branch/artifact.

For client-side Flutter routing, configure the hosting fallback/rewrite behavior so deep links resolve to `index.html`. GitHub Pages does not provide server-side rewrites by default; test direct navigation and page refreshes on nested routes. If those routes fail, configure Flutter's path strategy or use a host that supports SPA rewrites.

**Deployment note:** GitHub Pages serves static files over HTTPS. Add the deployed site URL to the Supabase Auth allowed redirect URLs and configure any required CORS/origin settings. Keep production environment values in GitHub Actions secrets or another secure deployment configuration; do not commit the local `keys.env`.

## 4. Technology stack

| Technology              | Purpose                                            | Why it was chosen                                       |
| ----------------------- | -------------------------------------------------- | ------------------------------------------------------- |
| Flutter / Dart          | Responsive application UI                          | Reusable UI and one codebase                            |
| GetX                    | State management, dependency injection and routing | Reactive state with limited boilerplate                 |
| Supabase                | Database, authentication, queries and RPC          | Hosted PostgreSQL backend without a separate API server |
| SharedPreferences 2.5.6 | Theme and local login flag persistence             | Lightweight local preferences                           |

The code follows a feature-first structure. `core/` contains shared theme, constants, widgets and download utilities; `app/routes/` contains route definitions; and `features/` contains authentication, catalogue, dashboard and enquiry modules.

## 5. Implemented functionality

- Admin email/password sign-in with a `user_roles` admin-role check.
- Responsive admin navigation and light/dark theme toggle.
- Product catalogue retrieval in batches of eight.
- Product search and category, price-range, occasion and customisation filters.
- Product create/update and active/inactive status updates through Supabase.
- Enquiry list, enquiry details and status updates: `New`, `Contacted`, `Converted`, and `Lost`.
- Dashboard enquiry totals through the `get_enquiry_stats` RPC.
- Previous/Next enquiry pagination controls, showing ten records per UI page.
- CSV generation and download for the enquiries currently loaded by the app.
- Tests covering pagination UI/controller behavior and theme behavior.

## 6. Incomplete work and known limitations

1. **Enquiry pagination is client-side.** `fetchEnquiries()` retrieves the full enquiry result set; filtering and Previous/Next pagination happen in memory. Move filtering, pagination and exact counts to Supabase for larger datasets.
2. **CSV export is limited to loaded records.** It does not independently fetch every matching enquiry. Update it to export all matching records in batches after server-side pagination is implemented.
3. **Authentication persistence needs hardening.** The splash flow trusts a SharedPreferences `login` boolean instead of validating the current Supabase session and admin role. Validate sessions, await preference writes, and handle expired or revoked sessions.
4. **Native CSV saving is incomplete.** Web uses a browser Blob download. The non-Web implementation writes to a local path where possible and does not provide a complete mobile share/save flow.
5. **Product image upload is not implemented.** Product records accept image URLs; an image picker and Supabase Storage upload workflow are not included.
6. **Email and push notifications are not implemented** in the supplied source archive.
7. **Backend and deployment configuration are absent.** Supabase SQL migrations, RLS definitions and deployment pipeline were not included and must be supplied and verified separately.

## 7. Recommended improvements

- Implement Supabase server-side enquiry pagination, filtering, search and exact counts.
- Make CSV export fetch all matching enquiries in batches, independently of the visible page.
- Replace the local login flag with Supabase session validation and protected admin routes.
- Add product image upload using Supabase Storage.
- Add email and Firebase Cloud Messaging notifications with retry handling and delivery logs.
- Expand tests for authentication, role denial, repository errors, CSV edge cases and product filters.
- Add CI checks for formatting, static analysis, tests and web deployment.

---

## 8. Time spent

**7 hours** — recorded estimate from the original project README. This figure has not been independently time-tracked or verified.
