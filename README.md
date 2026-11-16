# DriveNut — The Driver Community

DriveNut is a social community for drivers. It is not a ride-booking or driver-dispatch application.

## Current features

- Supabase email sign-up and sign-in
- Driver profiles stored in Supabase
- Shared community feed
- Create posts as stories, tips, questions, or discussions
- Like and comment on community posts
- Follow other driver profiles
- Save posts to your account
- Search the visible community feed
- Responsive desktop and mobile layout

## Project structure

- `index.html` — application layout and authentication interface
- `assets/styles.css` — responsive visual design
- `assets/app.js` — Supabase client and application interactions
- `supabase/schema.sql` — database schema and row-level security policies

## Supabase configuration

The browser app uses the Supabase project URL and **publishable** key. A publishable key is intended for client-side use; database access must remain protected by Row Level Security (RLS).

**Never put a Supabase secret key or service_role key in this repository or browser code.**

Email confirmation is enabled in the current project. New members must confirm their email before signing in.

## Deployment

GitHub Pages can host this static application. In **Settings → Pages**, select **Deploy from a branch**, choose `main` and `/(root)`, then save. Wait for the deployment to finish before sharing the Pages URL.

## Current limitations

- Photo uploads are not enabled yet.
- Notifications are a placeholder and are not generated yet.
- Communities are currently informational placeholders, not full group discussion spaces.
- Followers and profile statistics are basic; follower counts are not yet calculated.
- The initial sample/demo posts are not automatically inserted into the shared database. The feed starts with real member posts.
- This is an early implementation. Test account creation, email confirmation, posting, comments, likes, follows and saved posts before inviting other people.

## Safety and privacy

Use a display name rather than private contact information. Do not post passwords, identity documents, private addresses, or other sensitive information.
