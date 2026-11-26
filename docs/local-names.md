# Local names (auth.lapcloud.lan, photos.lapcloud.lan, ...)

Caddy gives each app a name like `http://photos.lapcloud.lan`. Your devices need to know that these names point to the LapCloud machine.

## 1. Find the machine IP

```bash
hostname -I
```

Use the first address, for example `192.168.1.50`. Give this machine a fixed IP in your router, so the address does not change.

## 2. Make the names work

**Option A: one device (quick test).** Add a line to the hosts file of that device.

On Linux or macOS:

```bash
echo "192.168.1.50 auth.lapcloud.lan photos.lapcloud.lan jellyfin.lapcloud.lan videos.lapcloud.lan audiobooks.lapcloud.lan books.lapcloud.lan music.lapcloud.lan" | sudo tee -a /etc/hosts
```

On Windows, edit `C:\Windows\System32\drivers\etc\hosts` as administrator and add the same line.

**Option B: the whole house.** In your router, add a local DNS rule that sends `*.lapcloud.lan` (or each name) to the machine IP. Not every router supports this.

## 3. Only on this machine

For a test on the LapCloud machine itself, set `LAPCLOUD_DOMAIN=localhost` in `core/caddy/.env`. Browsers resolve `auth.localhost` to this machine without extra setup.

## Why not just use the IP and port?

Single Sign-On (SSO) needs one address that both your browser and the containers can open. `localhost:9000` does not work from inside a container. A name like `auth.lapcloud.lan` does.

## Change the base name

Set `LAPCLOUD_DOMAIN` in `core/caddy/.env`, then restart Caddy:

```bash
cd core/caddy
docker compose up -d --force-recreate
```
