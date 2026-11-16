# DriveNut — The Driver Community

DriveNut is a social community for drivers. It is **not** a ride-booking or driver-dispatch application.

## Features

- Email sign-up, email confirmation, sign-in, password-reset email and password recovery through Supabase Auth
- Driver profiles with editable display name, driver type, bio and profile photo
- Community feed with stories, tips, questions and discussions
- Create text and photo posts, and delete your own posts
- Like, comment, follow and save posts
- Discover and search driver profiles
- Driver communities: join, leave and publish group discussions
- In-app notifications for likes, comments and follows, with individual and mark-all-as-read controls
- Realtime feed and notification updates
- Report posts and an admin-only safety reports dashboard
- Responsive desktop and mobile layout

## Project structure

- `index.html` — app layout and authentication interface
- `assets/styles.css` — responsive visual design
- `assets/app.js` — Supabase client and app interactions
- `supabase/schema.sql` — core tables and row-level security
- `supabase/storage.sql` — public media bucket and upload policies
- `supabase/notifications.sql` — notification triggers
- `supabase/communities.sql` — community tables and policies
- `supabase/realtime.sql` — realtime publication setup
- `supabase/post_reports.sql` — post-report table and policies
- `supabase/admin_moderation.sql` — admin-only report review policies
- `supabase/performance_indexes.sql` — optional indexes to speed up relationship, community and moderation queries
- `supabase/functions/delete-account/index.ts` — authenticated account deletion Edge Function
- `privacy.html`, `terms.html`, `community-guidelines.html` — public-facing policy and safety pages
- Existing installations can run `supabase/performance_indexes.sql` once to add the performance indexes

## Supabase setup

1. Create a Supabase project.
2. Run the SQL files in `supabase/` in the SQL Editor. Run each migration once; the scripts are designed to be safe to re-run where practical.
3. In Authentication settings, enable email sign-up and configure the Site URL and Redirect URL to the deployed GitHub Pages address.
4. The browser app uses the Supabase project URL and **publishable** key. Publishable keys are intended for client-side use; database access must be protected by Row Level Security (RLS).
5. Never place a Supabase secret key or `service_role` key in this repository or browser code.

### Account deletion setup

The profile editor includes a permanent account-deletion flow. Deploy `supabase/functions/delete-account/index.ts` as the `delete-account` Supabase Edge Function. Supabase-hosted Edge Functions receive the project URL and platform API-key environment variables automatically; do **not** try to create custom secrets whose names start with `SUPABASE_` (that prefix is reserved by the platform). In the Supabase Dashboard, confirm the function is deployed and that the platform-provided legacy `SUPABASE_SERVICE_ROLE_KEY` is available to the function runtime. If your project has migrated to the newer named API keys, update the function to read `SUPABASE_SECRET_KEYS` and select the intended server key before relying on account deletion.

The service-role/secret key must remain server-side and must never be placed in this repository, browser code, screenshots, or chat. The function verifies the caller's session, requires an explicit `DELETE` confirmation, removes files under that user's storage folder, then deletes the Auth user so foreign-key cascades remove account-linked database records. If media cleanup fails, it stops before deleting the account. Review this behavior and backups before enabling it for real members.

## Admin access

The safety dashboard checks the trusted Supabase Auth `app_metadata.role` claim for the value `admin`. Set this claim only through a trusted Supabase administrator process (for example, the SQL Editor updating `auth.users.raw_app_meta_data`). Never let users assign their own admin role through profile fields or `user_metadata`. After changing the claim, the admin must sign out and sign in again to refresh the JWT.

## Deployment

GitHub Pages hosts the static application. The repository includes `.github/workflows/deploy.yml`. In **Settings → Pages**, select **GitHub Actions** as the source. Every push to `main` triggers a deployment. Check the Actions tab for a successful **Deploy DriveNut to GitHub Pages** run.

Live site: https://iftekharshayem.github.io/drivenut-app/

## Public policies and launch readiness

The website includes starter Privacy, Terms and Community Guidelines pages. These are plain-language product drafts, not legal advice. Before public launch, the operator must obtain jurisdiction-specific legal review, publish a real privacy/support contact, confirm age and eligibility requirements, and implement a complete account-deletion process.

## Important limitations and launch checks

- Uploaded profile and post images are stored in a public Supabase Storage bucket. Do not upload private or sensitive images.
- The feed shows the latest 100 posts for the signed-in member.
- Realtime behavior should be tested with at least two separate accounts.
- Admin moderation supports reviewing report status and removing a reported post after an explicit confirmation. It does not suspend accounts or provide a full appeals workflow.
- The account-deletion interface and Edge Function source are included; the operator must deploy the function and configure its secrets before the control can work.
- Email confirmation is enabled; new members need to confirm their email before signing in.
- Before inviting members, test sign-up, email confirmation, sign-in, password recovery, profile editing, post creation/deletion, photo upload, likes, comments, follows, saved posts, communities, notifications and reporting with test accounts.

## Safety and privacy

Use a display name rather than private contact information. Do not post passwords, identity documents, private addresses or other sensitive information. Treat all public posts and uploaded media as visible to other people.
