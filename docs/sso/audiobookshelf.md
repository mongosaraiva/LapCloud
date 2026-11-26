# SSO for Audiobookshelf

Result: the Audiobookshelf login page gets a **Login with Authentik** button.

You need the three things listed in [README.md](README.md#before-you-start). The names used here are `auth.lapcloud.lan` and `audiobooks.lapcloud.lan`.

## Part 1: Authentik

Create the application and provider exactly as in [immich.md, Part 1](immich.md#part-1-authentik) (steps 1.1 to 1.3), but with these values.

**Step 1, Application**

| Field | Value |
|---|---|
| Application Name | `Audiobookshelf` |
| Slug | `audiobookshelf` (check that it is not repeated, see the warning in the Immich guide) |

**Step 3, Configure Provider**

| Field | Value |
|---|---|
| Authorization Flow | `default-provider-authorization-implicit-consent` |
| Client Type | Confidential |
| Grant Types | leave as the wizard sets them. **Authorization Code** must be ticked |
| Signing Key | `authentik Self-signed Certificate` |
| Redirect URIs | the three lines below, each one **Strict** |

```text
http://audiobooks.lapcloud.lan/audiobookshelf/auth/openid/callback
http://audiobooks.lapcloud.lan/audiobookshelf/auth/openid/mobile-redirect
audiobookshelf://oauth
```

> **The `/audiobookshelf` part is on purpose.** The Docker image serves the web app under `/audiobookshelf`, and Audiobookshelf has a setting called **Subfolder for Redirect URLs** set to `/audiobookshelf`. The redirect URIs must include it. The Audiobookshelf settings page shows the exact addresses next to that setting. If you change the subfolder there, change these URIs too.

When the provider is saved, copy the **Client ID** and the **Client Secret** (see step 1.3 of the Immich guide).

## Part 2: Audiobookshelf

### 2.1 Open the settings

Log in as the root user. Click the gear icon (**Settings**), then **Authentication** in the left menu.

### 2.2 Fill in the form

Tick **OpenID Connect Authentication**. The fields appear.

1. **Issuer URL**: `http://auth.lapcloud.lan/application/o/audiobookshelf/`
2. Click **Auto-populate**. Audiobookshelf asks Authentik and fills in the Authorize, Token, Userinfo, JWKS and Logout URLs by itself. If this fails, the server cannot open the Issuer URL (see the table at the end).
3. Fill in the rest:

| Field | Value |
|---|---|
| Client ID | from Part 1 |
| Client Secret | from Part 1 |
| Signing Algorithm | `RS256` (the default) |
| Allowed Mobile Redirect URIs | `audiobookshelf://oauth` (the default) |
| Subfolder for Redirect URLs | `/audiobookshelf` (the default) |
| Button Text | `Login with Authentik` |
| **Match existing users by** | **Match by username** |
| Auto Register | on, if you want new people created at their first login |
| Auto Launch | off, so you can still use the password form |

Leave the Group Claim and Advanced Permission Claim fields empty. Everyone gets the normal "user" role.

> **Why "Match by username" and not "Match by email"?** Authentik tells Audiobookshelf that the email is **not verified** by default. Audiobookshelf then refuses the login with `email ... is not verified` in its log. Matching by username has no such check. It works when the username in Authentik is the same as the username in Audiobookshelf.

### 2.3 Save and restart

Click **Save**. The page says: *Restart your server after saving to apply OIDC changes.* Do it:

```bash
cd media/audiobookshelf
docker compose restart
```

## Part 3: Test it

1. Log out of Audiobookshelf (or open a private window).
2. Click **Login with Authentik**.
3. Log in at Authentik if it asks.
4. You come back to Audiobookshelf, logged in.

## What happens to people

- **A person with the same username as an existing Audiobookshelf user** is linked to that user.
- **A new person** (with Auto Register on) gets a new user with the role "user". They see **no libraries** until you give them access. Go to **Settings → Users**, open the user and tick the libraries.

## If something does not work

Look at the Audiobookshelf log first:

```bash
cd media/audiobookshelf
docker compose logs --tail 50 audiobookshelf
```

| What you see | Cause | Fix |
|---|---|---|
| No **Login with Authentik** button | OIDC is not applied yet | Restart the container (2.3) |
| **Error in callback**, and the Authentik log says `Invalid grant_type` | **Authorization Code** is not ticked on the provider | Edit the provider in Authentik and tick it |
| Authentik shows an error about the redirect URI | The redirect URIs do not match | Check the three lines in Part 1. Do not forget `/audiobookshelf` |
| **Unauthorized** and `email ... is not verified` in the log | Matching by email | Use **Match by username** (2.2) |
| **Unauthorized** and no user is created | **Auto Register** is off and the username does not exist | Turn Auto Register on, or create the user first |
| **Auto-populate** fails | The container cannot open the Issuer URL | Check the Issuer URL and the slug. Check that Caddy is running |
| "Oops... No libraries available" | New user without library access | Give the user libraries (see above) |

## What was tested

Tested on a local copy with `localhost` as the base name (`auth.localhost`, `audiobooks.localhost`), Audiobookshelf 2.38:

- Auto-populate from the Issuer URL.
- Login with the **Login with Authentik** button.
- Auto-registering a new user (username `akadmin`) at the first login.
- The three problems in the table with `Invalid grant_type`, `Error in callback`, and `not verified`.

Not tested: the Audiobookshelf phone app, linking an existing Audiobookshelf user by username, and making the email count as verified in Authentik so that "Match by email" works.
