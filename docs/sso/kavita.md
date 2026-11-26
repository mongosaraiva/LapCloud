# SSO for Kavita

**Status: not possible yet with the plain HTTP setup. Kavita needs HTTPS.**

Kavita has built-in OpenID Connect (**Settings → Server → OpenID Connect**), but it refuses a login provider that does not use HTTPS. LapCloud runs on plain HTTP at home for now (see [local-names.md](../local-names.md)), so the Kavita connection cannot be done yet.

## What we saw

Tested on a local copy of LapCloud with Kavita (the `latest` image) and Authentik:

- In the form, the **Authority** field shows the error *The OIDC provider must use tls (https)* as soon as you type an `http://` address.
- The Kavita server also refuses it. Saving the setting through the API returns `HTTP 400` with `OIDC authority is invalid`. So this is not only the form.
- An `https://` address was refused too. Authentik does not answer on HTTPS in this setup, and Kavita checks the provider when you save.

There is no setting in Kavita's page to turn this check off.

## What to do

You have two choices:

1. **Keep using Kavita with its own users.** It works well without SSO. Create the accounts in Kavita (**Settings → Users**).
2. **Wait for HTTPS.** HTTPS needs a real domain name and certificates, which is the step where LapCloud goes from "only at home" to "reachable from the internet". When LapCloud has HTTPS, this guide will be written and tested.

## What will be needed later

These are the settings we saw on the Kavita page. They are listed so you know what the guide will cover. **They have not been tested end to end.**

In Kavita (**Settings → Server → OpenID Connect**):

| Setting | Notes |
|---|---|
| Authority | The Authentik address of the application, with `https://` |
| Client ID, Client secret | From the Authentik provider. Kavita must be a **confidential** client |
| Provision accounts | Creates a Kavita account at the first login |
| Require verified emails | Authentik says the email is **not verified** by default, so this switch will probably need to be off. See [README.md](README.md#rules-that-apply-to-every-app) |
| Sync user settings with OIDC roles | If off, new users see no content until you give them libraries |

Kavita also says that changing the provider settings needs a **manual restart** of the container.

## Tell us

If you set up HTTPS on your own and want this guide sooner, open an issue in the repository.
