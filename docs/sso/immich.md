# SSO for Immich

Result: the Immich login page gets a **Login with Authentik** button.

You need the three things listed in [README.md](README.md#before-you-start). The names used here are `auth.lapcloud.lan` and `photos.lapcloud.lan`.

## Part 1: Authentik

### 1.1 Open the admin interface

Log in at `http://auth.lapcloud.lan/`. Click **Admin interface** (Interface de administração) at the top right.

### 1.2 Create the application and the provider

Go to **Applications → Applications** and click **New Application**. A wizard with 5 steps opens.

**Step 1, Application**

| Field | Value |
|---|---|
| Application Name | `Immich` |
| Slug | `immich` |

> **Careful with the slug.** It fills itself from the name. Check that it says exactly `immich`. If you type it again on top, you get `immichimmich`, and the Issuer URL in Part 2 will not work.

**Step 2, Choose a Provider**

Select **OAuth2/OpenID Provider**.

**Step 3, Configure Provider**

| Field | Value |
|---|---|
| Authorization Flow | `default-provider-authorization-implicit-consent` |
| Client Type | Confidential (the default) |
| Redirect URIs | the three lines below, each one with mode **Strict** |
| Signing Key | `authentik Self-signed Certificate` (the default) |

> **Choose the Authorization Flow yourself.** The field starts empty (it says "Loading..." for a moment). If you leave it empty, the last step fails with "there was an error in the provider".
>
> *Implicit consent* logs people in without asking "Do you allow this app?" every time. Pick *explicit consent* if you want that question.

Click **Add entry** (Adicionar entrada) three times and type one address in each. Keep the type **Strict** and **Authorization**:

```text
http://photos.lapcloud.lan/auth/login
http://photos.lapcloud.lan/user-settings
app.immich:///oauth-callback
```

The first two are for the web page. The third is for the Immich phone app.

Leave the Signing Key as it is. Immich needs a key (the login uses RS256). With the default, it works.

**Step 4, Configure Bindings**

Leave it empty. Everyone in Authentik can then use Immich. (To limit it, bind a group here.)

**Step 5, Review and Submit**

Click **Create application** (Criar aplicativo).

### 1.3 Copy the Client ID and the Secret

Open the new application (click **Immich** in the list). Click the provider link (**Provider for Immich**). The provider page shows:

- **Client ID** (ID do cliente)
- **OpenID Configuration Issuer** (Emissor de configuração OpenID). This is the Issuer URL you need in Part 2.

The **Client Secret** (Segredo do cliente) is not on that page. Click **Edit** (Editar) and copy it from the form.

> **Copy them now, from the saved provider.** Do not copy them from the wizard form. If you go back a step in the wizard, it can make a new secret, and the one you copied stops working. The symptom is `invalid_client` in the Immich log. Going back in the wizard can also repeat the redirect URIs. That is harmless.

### 1.4 Check the address

Open this in your browser. You should see text (JSON) and not an error page:

```text
http://auth.lapcloud.lan/application/o/immich/.well-known/openid-configuration
```

The line `"issuer"` must be `http://auth.lapcloud.lan/application/o/immich/`. This is the **Issuer URL** you need next, with the final `/`.

## Part 2: Immich

### 2.1 Open the OAuth settings

Log in to Immich as admin. Go to **Administration → Settings → Authentication Settings → OAuth** (Definições de Autenticação → OAuth).

If Immich shows a welcome wizard, you can go straight to `http://photos.lapcloud.lan/admin/system-settings?isOpen=authentication+oauth`.

### 2.2 Fill in the form

Turn on **Login with OAuth** (Iniciar sessão com o OAuth). More fields appear.

| Field | Value |
|---|---|
| Issuer URL | `http://auth.lapcloud.lan/application/o/immich/` |
| Client ID | from step 1.3 |
| Client Secret | from step 1.3 |
| Scope | `openid email profile` (the default) |
| Token endpoint auth method | `client_secret_post` (the default) |
| ID token signed response alg | `RS256` (the default) |
| Userinfo signed response alg | `RS256` (the default) |
| Button text (Texto do botão) | `Login with Authentik` |
| Auto register (Registo automático) | on (the default) |
| **Allow insecure requests** (Permitir pedidos inseguros) | **on** |

> **Why "Allow insecure requests"?** Your home setup uses plain HTTP. Without this switch, Immich refuses to talk to Authentik and says `only requests to HTTPS are allowed`. The warning on the switch is about disabling TLS checks. On plain HTTP there is no TLS to check, so nothing extra is lost. If you later move to HTTPS with a real domain, turn this switch off.

Click **Save** (Guardar).

### 2.3 What "Auto register" does

- **A person who already has an Immich account** with the same email is linked to it at the first SSO login.
- **A person who does not** gets a new Immich account created automatically (if Auto register is on).

So make the email in Authentik the same as the email in Immich. If the emails are different, you get a second, empty account.

## Part 3: Test it

1. Log out of Immich.
2. On the login page, click **Login with Authentik**.
3. Log in at Authentik if it asks.
4. You come back to Immich, logged in.

To confirm in the Immich admin page: **Administration → Users**. The user is the same one as before.

## If something does not work

Look at the Immich log first:

```bash
cd media/immich
docker compose logs --tail 50 immich-server
```

| What you see | Cause | Fix |
|---|---|---|
| `only requests to HTTPS are allowed` | Plain HTTP | Turn on **Allow insecure requests** (2.2) |
| `invalid_client` | Wrong Client ID or Secret | Copy them again from the saved provider (1.3) |
| `Error in OAuth discovery` or no button | Immich cannot open the Issuer URL | Check 1.4. Check the slug. Check that Caddy is running |
| Authentik shows an error about the redirect URI | The redirect URIs do not match | Check the three lines in step 3. They must be **Strict** and identical |
| 404 on `.well-known/openid-configuration` | Wrong slug (for example `immichimmich`) | Open the application in Authentik and fix the slug |
| A "name not found" type of error in the log | The container cannot find `auth.lapcloud.lan` | Check that Caddy is running and that its `LAPCLOUD_DOMAIN` is the same name you used |

## What was tested

Tested on a local copy, with `localhost` as the base name (`auth.localhost`, `photos.localhost`):

- Creating the application and provider in Authentik with the steps above.
- Immich reaching the Issuer URL from inside its container.
- Login with the **Login with Authentik** button, linking an existing Immich admin by email.

Not tested yet: the Immich phone app, auto-registering a new user, and a custom base name such as `lapcloud.lan` in a real browser on another device.
