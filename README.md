# DriveNut

A mobile-friendly rider/driver connection project. This repository currently contains a front-end preview and the first Supabase database schema.

## Project structure

- `index.html` — app entry page
- `assets/styles.css` — responsive UI styles
- `assets/app.js` — browser-side demo interactions
- `supabase/schema.sql` — initial PostgreSQL schema and row-level security policies

## Run locally

Open `index.html` in a browser, or serve this folder with any static web server.

## Publish a preview with GitHub Pages

1. Open the repository **Settings → Pages**.
2. Under **Build and deployment**, choose **Deploy from a branch**.
3. Select branch **main** and folder **/(root)**, then Save.
4. Wait for GitHub Pages to publish the site; the Pages section will show its URL.

## Backend setup (next integration step)

1. Create a Supabase project.
2. Open **SQL Editor** and run `supabase/schema.sql`.
3. Configure Supabase Auth and decide which sign-in method to enable.
4. Add the Supabase project URL and public anon key to the front-end integration when ready. Never put a service-role key in browser code.

## Important status

The current ride and join forms are a local browser demo. They do not contact drivers, send registrations to a server, or provide real authentication. The SQL file is a starting database foundation; Supabase credentials and application integration are not configured yet. Do not use this preview for real rides or sensitive personal information.
