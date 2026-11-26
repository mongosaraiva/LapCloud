# SSO for Navidrome

Result: when you open `http://music.lapcloud.lan`, Authentik asks you to log in, and then Navidrome opens already logged in as you. There is no button, because Navidrome does not have OpenID.

## How it is different

Navidrome has no OpenID login. Instead, it can trust a **user name sent by a proxy**. So here:

1. **Caddy** asks Authentik "is this person logged in?" before it shows any page (this is called *forward auth*).
2. If yes, Caddy passes the Authentik user name to Navidrome in a header called `Remote-User`.
3. **Navidrome** trusts that header, but only when it comes from the LapCloud network.

You need the three things listed in [README.md](README.md#before-you-start). The names used here are `auth.lapcloud.lan` and `music.lapcloud.lan`.

## Part 1: Authentik

This is a **Proxy Provider**, not OAuth2, so the settings are different from the other guides.

### 1.1 Create the application and the provider

Go to **Applications → Applications → New Application** (see step 1.2 of [immich.md](immich.md#part-1-authentik) for the wizard).

| Step | Field | Value |
|---|---|---|
| 1, Application | Application Name | `Navidrome` |
| 1, Application | Slug | `navidrome` (check that it is not repeated) |
| 2, Choose a Provider | Type | **Proxy Provider** |
| 3, Configure Provider | Authorization Flow | `default-provider-authorization-implicit-consent` |
| 3, Configure Provider | Mode | **Forward auth (single application)** |
| 3, Configure Provider | External host | `http://music.lapcloud.lan` |

Finish the wizard.

### 1.2 Give the application to the embedded outpost

The *outpost* is the part of Authentik that answers Caddy. Authentik has one built in.

1. Go to **Applications → Outposts** and click the edit icon of **authentik Embedded Outpost**.
2. In **Applications**, move **Navidrome** from *Available* to *Selected*.
3. Open **Advanced settings**. In **Configuration**, set `authentik_host` to the address of Authentik that your browser uses:

```yaml
authentik_host: http://auth.lapcloud.lan
```

4. Click **Save Changes**.

> **Do not skip `authentik_host`.** If it is empty, the login redirect points to `http://localhost/...` and the login breaks. We saw this in the test.

## Part 2: Caddy

Replace the whole content of `core/caddy/sites/navidrome.caddy` with:

```text
http://music.{$LAPCLOUD_DOMAIN} {
	# Never trust a Remote-User header sent by a client
	request_header -Remote-User

	# Login and callback pages of the Authentik outpost
	reverse_proxy /outpost.goauthentik.io/* lapcloud-authentik-server:9000

	# Music apps (phone, desktop) use the Subsonic API with their own Navidrome password
	@subsonic path /rest/*
	handle @subsonic {
		reverse_proxy lapcloud-navidrome:4533
	}

	# The web page: ask Authentik first, then tell Navidrome who it is
	handle {
		forward_auth lapcloud-authentik-server:9000 {
			uri /outpost.goauthentik.io/auth/caddy
			copy_headers X-Authentik-Username>Remote-User
			trusted_proxies private_ranges
		}
		reverse_proxy lapcloud-navidrome:4533
	}
}
```

Then reload Caddy:

```bash
cd core/caddy
docker compose restart
```

> **Why `request_header -Remote-User`?** Navidrome trusts the `Remote-User` header. Without this line, anyone on your network could send `Remote-User: admin` on the music-app address (`/rest/...`) and be accepted as that user. In the test, with the line, the forged header was dropped. Keep it.

## Part 3: Navidrome

Find the address range of the `lapcloud` Docker network:

```bash
docker network inspect lapcloud -f '{{(index .IPAM.Config 0).Subnet}}'
```

It prints something like `172.22.0.0/16`. Add these two lines to `media/navidrome/.env`, with your own range:

```text
ND_EXTAUTH_TRUSTEDSOURCES=172.22.0.0/16
ND_EXTAUTH_USERHEADER=Remote-User
```

Apply them:

```bash
cd media/navidrome
docker compose up -d
```

## Part 4: Test it

1. Open a private window and go to `http://music.lapcloud.lan`.
2. Authentik asks you to log in.
3. You come back to Navidrome, logged in with your Authentik user name.

You can also test without a browser. This must answer `302` and a `Location` that starts with your Authentik address:

```bash
curl -s -o /dev/null -D - -H "Host: music.lapcloud.lan" http://localhost/ | head -3
```

## What happens to people

- **The first person who logs in becomes the Navidrome administrator.** So log in yourself first. Everyone after that gets a normal user. (We saw the first user, `akadmin`, created as admin.)
- **A new person** gets a Navidrome user with the same name as in Authentik, created at the first login.
- **Music apps on a phone or computer** (anything that uses the Subsonic API) do **not** use SSO. They log in with a Navidrome user name and password, because the `/rest/` address is not behind Authentik. Set that password inside Navidrome.

## What this does not protect

- Every container on the `lapcloud` network is trusted by Navidrome, since the trusted range is the whole network. Do not put containers you do not trust on it.
- The `/rest/` address is open to the network and only protected by the Navidrome password.

## If something does not work

| What you see | Cause | Fix |
|---|---|---|
| Navidrome opens without asking for a login | The Caddy site file was not replaced, or Caddy was not restarted | Check Part 2 |
| The login goes to `http://localhost/...` | `authentik_host` is empty | Set it (1.2, step 3) |
| Navidrome shows its own login form | Navidrome does not trust the header, or the Authentik outpost is not working | Check the range in `ND_EXTAUTH_TRUSTEDSOURCES` (Part 3). Check that **Navidrome** is in the *Selected* applications of the outpost (1.2) |

For anything else, look at the log:

```bash
cd media/navidrome
docker compose logs --tail 50 navidrome
```

## What was tested

Tested on a local copy with `localhost` as the base name (`auth.localhost`, `music.localhost`), Navidrome 0.64.2:

- A request without a login is sent to Authentik (`302`).
- Login in a browser; Navidrome created the user `akadmin`, as administrator because it was the first user.
- A forged `Remote-User` header is dropped by Caddy on the web page and on `/rest/`.
- The login redirect breaks when `authentik_host` is empty.

Not tested: the exact clicks of the Proxy Provider wizard in Authentik (the provider was made through the API with the same settings), a second user, signing out, and the phone and desktop music apps.
