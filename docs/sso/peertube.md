# SSO for PeerTube

**Status: not possible yet with the plain HTTP setup. The PeerTube plugin needs HTTPS.**

PeerTube has no OpenID login built in. The official plugin **auth-openid-connect** adds it, and it installs and shows its button without problems. But when you click the button, the plugin refuses to talk to a login provider that is not HTTPS. LapCloud runs on plain HTTP at home for now (see [local-names.md](../local-names.md)), so the connection cannot be finished yet.

## What we saw

Tested on a local copy of LapCloud with PeerTube (image `production-bookworm`), plugin **auth-openid-connect 1.2.0** and Authentik:

1. **Administration → Settings → Plugins/Themes → Search plugins** lists **auth-openid-connect** as an official plugin. It installs without a restart.
2. Its settings page saved fine. The page has these fields: *Auth display name, Discover URL, Client ID, Client secret, Scope, Username property, Email property, Logout redirect URI, Allowed external redirect URIs, Display name property, Role property, Group property, Allowed group, Token signature algorithm.*
3. After saving, the login page shows **Or sign in with: Authentik**.
4. Clicking the button does nothing. The PeerTube log shows:

```text
Cannot handle auth request - OpenID provider unavailable.
only requests to HTTPS are allowed   (code: OAUTH_HTTP_REQUEST_FORBIDDEN)
```

There is **no setting** in the plugin page to allow plain HTTP. (Immich has one, which is why its guide works. See [immich.md](immich.md).)

## What to do

You have two choices:

1. **Keep using PeerTube with its own accounts.** The root user is created at the first start. See [install-laptop.md](../install-laptop.md) for how to find its password. More users can be created in **Administration → Users**.
2. **Wait for HTTPS.** HTTPS needs a real domain name and certificates, which is the step where LapCloud goes from "only at home" to "reachable from the internet". That step is also what PeerTube needs to talk to other PeerTube servers (federation). When LapCloud has HTTPS, this guide will be written and tested.

## What will be needed later

These are the values seen on the plugin page. They are listed so you know what the guide will cover. **They have not been tested end to end.**

| Plugin field | Value |
|---|---|
| Auth display name | the text on the button, for example `Authentik` |
| Discover URL | the Authentik address of the application ending in `/.well-known/openid-configuration`, with `https://` |
| Client ID, Client secret | from the Authentik provider |
| Scope | `openid email profile` (the default) |
| Username property | `preferred_username` (the default) |
| Email property | `email` (the default) |
| Token signature algorithm | `RS256` (the default) |

In Authentik, the redirect URI of the provider will be the PeerTube address followed by `/plugins/auth-openid-connect/router/code-cb`. This comes from the plugin documentation and was not reached in our test.

## Tell us

If you set up HTTPS on your own and want this guide sooner, open an issue in the repository.
