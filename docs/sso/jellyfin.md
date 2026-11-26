# SSO for Jellyfin

Result: the Jellyfin login page gets a **Login with Authentik** button.

Jellyfin has no OpenID login built in. It needs a plugin from a third party, **SSO Authentication** (by 9p4). Jellyfin warns you that third-party plugins carry risks. This guide uses that plugin.

You need the three things listed in [README.md](README.md#before-you-start). The names used here are `auth.lapcloud.lan` and `jellyfin.lapcloud.lan`. The Jellyfin container needs internet access to download the plugin.

## Part 1: Authentik

Create the application and provider exactly as in [immich.md, Part 1](immich.md#part-1-authentik) (steps 1.1 to 1.3), but with these values.

**Step 1, Application**

| Field | Value |
|---|---|
| Application Name | `Jellyfin` |
| Slug | `jellyfin` (check that it is not repeated) |

**Step 3, Configure Provider**

| Field | Value |
|---|---|
| Authorization Flow | `default-provider-authorization-implicit-consent` |
| Client Type | Confidential |
| Grant Types | leave as the wizard sets them. **Authorization Code** must be ticked |
| Signing Key | `authentik Self-signed Certificate` |
| Redirect URIs | the line below, **Strict** |

```text
http://jellyfin.lapcloud.lan/sso/OID/redirect/authentik
```

> The last word, `authentik`, is the **name of the provider** you choose in Part 2. They must be the same, letter for letter. If you use another name in Part 2, change it here too.

When the provider is saved, copy the **Client ID** and the **Client Secret** (see step 1.3 of the Immich guide).

## Part 2: Jellyfin

### 2.1 Install the plugin

Log in to Jellyfin as admin and go to **Dashboard → Plugins → Repositories** (Painel de controlo → Plugins → Repositórios).

1. Click **New repository** (Novo repositório).
2. **Repository name:** `SSO Authentication`
3. **Repository URL:**

```text
https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json
```

4. Click **Add** (Adicionar).
5. Go back to **Plugins**. Click the filter **Available** (Disponível) and search for `SSO`.
6. Click **SSO Authentication**, then **Install** (Instalar). Confirm the warning about third-party plugins.
7. Restart Jellyfin:

```bash
cd media/jellyfin
docker compose restart
```

### 2.2 Configure the plugin

Open `http://jellyfin.lapcloud.lan/web/#/configurationpage?name=SSO-Auth` (or **Dashboard → Plugins → SSO-Auth**). You see a long form. Fill in these fields:

| Field | Value |
|---|---|
| Name of OpenID Provider | `authentik` (the same as the end of the redirect URI in Part 1) |
| OpenID Endpoint | `http://auth.lapcloud.lan/application/o/jellyfin/` |
| OpenID Client ID | from Part 1 |
| OpenID client secret | from Part 1 |
| Enabled | ticked |
| Enable Authorization by Plugin | ticked |
| Enable All Folders | ticked, if everyone may see all libraries |
| **Disable OpenID HTTPS Discovery (Insecure)** | **ticked** |

Leave the other fields as they are. Roles, Admin Roles and the Live TV options can stay empty.

> **Why "Disable OpenID HTTPS Discovery"?** Your home setup uses plain HTTP, and the plugin refuses an HTTP provider unless you tick this. If you later move to HTTPS, untick it.

Click **Save** at the bottom of the page. Then restart Jellyfin again. The plugin says that every change to this page needs a restart:

```bash
cd media/jellyfin
docker compose restart
```

### 2.3 Add the login button

The plugin does not add a button by itself. You add one with a small piece of HTML.

Go to **Dashboard → Branding** (Painel de controlo → Personalização). In the box **Login disclaimer** (Aviso legal de início de sessão), paste:

```html
<form action="/sso/OID/start/authentik"><button class="raised block emby-button button-submit">Login with Authentik</button></form>
```

Click **Save** (Guardar). The word `authentik` in the address is the provider name again.

## Part 3: Test it

1. Log out of Jellyfin.
2. On the login page, below the password form, click **Login with Authentik**.
3. Log in at Authentik if it asks.
4. You come back to Jellyfin, logged in.

You can also test without the button by opening `http://jellyfin.lapcloud.lan/sso/OID/start/authentik`. It sends you to Authentik.

## What happens to people

- **A new person** gets a Jellyfin user with the same name as in Authentik. It is **not** an administrator. With **Enable All Folders** on, they see all libraries.
- To make someone an administrator, do it in Jellyfin as for any user (**Dashboard → Users**). The plugin also has an **Admin Roles** field, which needs a roles claim from Authentik. That is not covered here and was not tested.

## If something does not work

Look at the Jellyfin log first:

```bash
cd media/jellyfin
docker compose logs --tail 50 jellyfin
```

| What you see | Cause | Fix |
|---|---|---|
| The plugin is not in the **Available** list | The repository was not added, or there is no internet | Check step 2.1. Check that the URL is exact |
| `/sso/OID/start/authentik` does not send you to Authentik | The plugin settings are not saved or Jellyfin was not restarted | Save the plugin page and restart Jellyfin (2.2) |
| Authentik shows an error about the redirect URI | The provider name differs, or a typo | The redirect URI must be `.../sso/OID/redirect/<provider name>`, with the same name as in Part 2 |
| `Invalid grant_type` in the Authentik log | **Authorization Code** is not ticked on the provider | Edit the provider in Authentik and tick it |
| The button does not show | The HTML was not saved | Check **Dashboard → Branding** (2.3) |

## What was tested

Tested on a local copy with `localhost` as the base name (`auth.localhost`, `jellyfin.localhost`), Jellyfin 12.4 and plugin SSO Authentication 4.0.0.4:

- Adding the repository, installing the plugin and restarting.
- Configuring the plugin on its settings page.
- The login button, and a login that created the Jellyfin user `akadmin` (not an admin).

The plugin says it was made for Jellyfin 10.11. It loaded and worked on 12.4.

Not tested: the Jellyfin phone and TV apps (the button is on the web login page, so those apps probably do not show it), linking to a Jellyfin user that already exists, roles from Authentik, and a custom base name such as `lapcloud.lan` in a browser on another device.
