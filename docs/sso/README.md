# Single Sign-On (SSO) with Authentik

With SSO you log in once, with one account, and every app shows a button like **Login with Authentik**. You create users in one place (Authentik) and not in each app.

## How it works

For each app you create two things in Authentik:

- an **Application** (the name people see), and
- a **Provider** (OAuth2/OpenID). It gives you a **Client ID** and a **Client Secret**.

Then you paste the address of Authentik, the Client ID and the Client Secret into the app's settings. That is all.

```text
Browser ──> app (Immich) ──> "go log in at Authentik" ──> Authentik
                                                              │ you log in
Browser <── app <── "this person is admin@lapcloud.lan" <─────┘
```

## Before you start

1. Authentik is running and you created the admin user. See [install-laptop.md](../install-laptop.md).
2. Caddy is running and the names work in your browser. See [local-names.md](../local-names.md).
3. The app you want to connect is running.

> **Why the names matter.** The app (a container) must open the **same** address as your browser, for example `http://auth.lapcloud.lan`. That is why `localhost:9000` does not work for SSO. Caddy has these names as aliases on the `lapcloud` Docker network, so containers find them.

In this guide the base name is `lapcloud.lan`. If you changed `LAPCLOUD_DOMAIN`, use your own name everywhere.

## Language

Authentik and the apps use the language of your browser. This guide uses the English names. The Portuguese names are in brackets when they are different.

## Apps

| App | SSO method | Guide |
|---|---|---|
| Immich | OAuth, built in | [immich.md](immich.md) (tested) |
| Jellyfin | Third-party plugin | [jellyfin.md](jellyfin.md) (tested) |
| PeerTube | Official plugin, but **needs HTTPS** | [peertube.md](peertube.md) (not possible yet) |
| Audiobookshelf | OpenID, built in | [audiobookshelf.md](audiobookshelf.md) (tested) |
| Kavita | OpenID, built in, but **needs HTTPS** | [kavita.md](kavita.md) (not possible yet) |
| Navidrome | No OpenID. Needs proxy login | not written yet |
| Veloren | No SSO | none |

The "SSO method" column is what the projects document, and it can change between versions. Each guide is written only after it is tested here.

## Rules that apply to every app

- **The email must match.** Apps link your SSO login to an existing user by email. Use the same email in Authentik and in the app.
- **Copy the Client ID and Secret after you create the provider**, not before. See the warning in [immich.md](immich.md).
- **Leave the Grant Types as the wizard sets them.** **Authorization Code** must be ticked, or the login fails with `Invalid grant_type`.
- **Authentik says the email is not verified.** Some apps refuse to link an account by an unverified email. Match by username in those apps.
- **Home network, plain HTTP.** Some apps refuse a login address that is not HTTPS. Some have a switch to allow it (Immich, Audiobookshelf, Jellyfin). Others do not (Kavita, PeerTube), and then SSO has to wait for HTTPS. Each guide says which.
- **Keep one admin you can still log in with by password**, in every app, until you are sure SSO works. If Authentik is down, SSO logins fail.
