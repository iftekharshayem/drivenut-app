# DriveNut — The Driver Community

DriveNut is a social community concept for drivers. It is not a ride-booking or driver-dispatch application.

## Community features in this first UI build

- Community feed with sample driver posts
- Create posts as stories, tips, questions, or discussions
- Like and comment on posts
- Follow suggested community members
- Search the visible feed
- Save posts
- Edit a local demo profile
- Responsive desktop and mobile layout

## Project structure

- `index.html` — community application layout
- `assets/styles.css` — responsive visual design
- `assets/app.js` — front-end demo interactions
- `supabase/schema.sql` — initial Supabase/PostgreSQL schema for profiles, posts, comments, likes, follows, saved posts, and notifications

## Preview

Enable GitHub Pages in **Settings → Pages**:
1. Choose **Deploy from a branch**.
2. Select `main` and `/(root)`.
3. Save and wait for the published URL.

## Current implementation status

The current browser build is a front-end prototype. Demo posts and interactions are stored only in the current browser's local storage. They are not shared between different users or devices. The suggested profiles and sample posts are demonstration content.

The Supabase schema is a database foundation only. Supabase is not yet connected to the website, and real sign-up, sign-in, shared posts, cloud image uploads, notifications, and cross-device follow/like/comment are not live yet.

## Authentication note

A secure username-and-password-only sign-in needs a trusted server-side authentication flow; do not store raw passwords in browser storage or create a fake login. The project can use a secure supported Supabase Auth flow while presenting a username as the public identity. Do not put a Supabase service-role key in front-end code.

## Safety and privacy

Use sample information in this preview. Do not post private contact details, passwords, identity documents, or sensitive personal information.