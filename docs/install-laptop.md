# Install LapCloud on a laptop (Debian)

This guide takes you from a fresh Debian laptop to a running LapCloud.

**Before you start**

- A laptop with 8 GB of RAM or more is comfortable. With less, start only the apps you need. Immich and PeerTube use the most memory.
- Plug it in and keep it on the network cable if you can.
- In your router, give the laptop a fixed IP address.

## 1. Install Docker

Remove old packages that conflict:

```bash
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)
```

Add Docker's official repository:

```bash
sudo apt update
sudo apt -y install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Install Docker and start it:

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

Let your user run Docker without `sudo`, then log out and log in again:

```bash
sudo usermod -aG docker $USER
```

Check that it works:

```bash
docker ps
```

## 2. Get LapCloud

```bash
git clone https://github.com/mongosaraiva/LapCloud.git
cd LapCloud
docker network create lapcloud
```

## 3. Start the core services

Postgres first:

```bash
cd core/postgres
cp .env.example .env     # edit .env: set POSTGRES_PASSWORD
docker compose up -d
docker compose ps        # wait for "healthy"
```

Then Caddy (the proxy that gives each app a name):

```bash
cd ../caddy
cp .env.example .env     # edit .env if you want a different base name
docker compose up -d
```

Make the names work on your devices by following [local-names.md](local-names.md).

Then Authentik:

```bash
cd ../authentik
cp .env.example .env     # edit .env: set AUTHENTIK_SECRET_KEY and the database password
./create-db.sh
docker compose up -d
```

The first start takes a few minutes (up to about three), while Authentik prepares its database. Then open `http://auth.lapcloud.lan/` and create the admin user. Use the root address, not `/if/flow/initial-setup/`: that page refuses a direct visit with "request denied". The form asks for an email, a password and the **Base URL** (leave it as `http://auth.lapcloud.lan`, with no path).

## 4. Start the apps you want

Every app follows the same steps. Example with Jellyfin:

```bash
cd ../../media/jellyfin
cp .env.example .env     # edit .env: set MEDIA_DIR to your movies folder
docker compose up -d
```

| App | Folder | Address | Extra step |
|---|---|---|---|
| Immich | `media/immich` | `http://photos.lapcloud.lan` | Set `DB_PASSWORD` in `.env` |
| Jellyfin | `media/jellyfin` | `http://jellyfin.lapcloud.lan` | Set `MEDIA_DIR` |
| PeerTube | `media/peertube` | `http://videos.lapcloud.lan` | Set the secret and DB password, then run `./create-db.sh` |
| Audiobookshelf | `media/audiobookshelf` | `http://audiobooks.lapcloud.lan` | Set `AUDIOBOOKS_DIR` and `PODCASTS_DIR` |
| Kavita | `media/kavita` | `http://books.lapcloud.lan` | Set `BOOKS_DIR` |
| Navidrome | `media/navidrome` | `http://music.lapcloud.lan` | Set `MUSIC_DIR` |
| Veloren | `gaming/veloren` | `<laptop-ip>:14004` (game client) | None |

PeerTube creates its `root` password on the first start. Find it with:

```bash
cd media/peertube
docker compose logs peertube | grep "User password"
```

## 5. Everyday commands

See what is running:

```bash
docker ps
```

Update an app (from its folder):

```bash
docker compose pull
docker compose up -d
```

Stop an app (from its folder):

```bash
docker compose down
```

Your data stays in the app's `data/` folder, so stopping does not delete it.

## If something does not work

- **`network lapcloud not found`**: run `docker network create lapcloud`.
- **`permission denied` with Docker**: log out and log in again after `usermod`.
- **Name does not open in the browser**: check [local-names.md](local-names.md).
- **Caddy shows "unknown name"**: the name in the address is not the one in `LAPCLOUD_DOMAIN`.
- **Port 80 is busy**: set `CADDY_HTTP_PORT` in `core/caddy/.env`.
- **See what an app says**: `docker compose logs --tail 50` in its folder.

## Single Sign-On

To log in to your apps with one account, see [sso/README.md](sso/README.md).

## Back up your data

See [backup-restore.md](backup-restore.md).
