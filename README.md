# LapCloud

<p align="center">
  <img src="Storyboard%20animado%20do%20LapCloud.gif" alt="LapCloud animated storyboard" width="800">
</p>

<p align="center">
  <strong>Take back your data. Own your cloud.</strong>
</p>

<p align="center">
  A beginner-friendly, Docker-powered self-hosting stack that turns your laptop into your own personal cloud.
</p>

<p align="center">
  Your hardware. Your cloud. Your rules.
</p>



## About

LapCloud is an open-source project designed to make self-hosting accessible to everyone.

Start with a laptop and gradually build your own personal cloud. Deploy your favorite open-source applications to manage photos, stream media, listen to music, read books, host videos, and even run your own multiplayer gaming server.

No dedicated server required. No expensive infrastructure. Just your hardware and Docker.

**Start small. Self-host everything. Take back control.**

## Applications

LapCloud brings together specialized open-source applications in one modular environment.

### Core

| Application | Description | Address |
|---|---|---|
| [Caddy](https://caddyserver.com/) | Reverse proxy: gives each app a friendly name | none (it is the entry point) |
| [Postgres](https://www.postgresql.org/) | Shared database for Authentik and PeerTube | internal only |
| [Authentik](https://goauthentik.io/) | Identity management and Single Sign-On (SSO) | `http://auth.lapcloud.lan` |

### Media & Entertainment

| Application | Description | Address |
|---|---|---|
| [Immich](https://immich.app/) | Self-hosted photo and video management | `http://photos.lapcloud.lan` |
| [Jellyfin](https://jellyfin.org/) | Movies, TV shows and media streaming | `http://jellyfin.lapcloud.lan` |
| [PeerTube](https://joinpeertube.org/) | Video hosting and sharing | `http://videos.lapcloud.lan` |
| [Audiobookshelf](https://www.audiobookshelf.org/) | Audiobooks and podcast management | `http://audiobooks.lapcloud.lan` |
| [Kavita](https://www.kavitareader.com/) | Ebooks, manga, comics and reading | `http://books.lapcloud.lan` |
| [Navidrome](https://www.navidrome.org/) | Personal music streaming server | `http://music.lapcloud.lan` |

### Gaming

| Application | Description | Address |
|---|---|---|
| [Veloren](https://veloren.net/) | Open-source multiplayer voxel RPG with third-person gameplay | `<machine-ip>:14004` (game client) |

The `lapcloud.lan` base name can be changed. See [docs/local-names.md](docs/local-names.md).

## Supported Hardware

LapCloud follows a **Laptop First** approach, but is designed to expand beyond laptops.

| Platform | Target |
|---|---|
| Laptop | Primary development and installation platform |
| Raspberry Pi | Single-board computer deployments |
| Other SBCs | ARM-based home servers |
| Mini PCs | Compact, always-on personal clouds |
| Desktop PCs | Higher-performance deployments |

Hardware and CPU architecture compatibility depends on the individual application.

**Tested so far:** an x86-64 laptop running Debian. Raspberry Pi, other ARM boards, mini PCs and desktops are not tested yet.

## Repository Structure

```text
LapCloud/
│
├── core/
│   ├── postgres/         shared database
│   ├── caddy/            reverse proxy (one file per app in sites/)
│   └── authentik/        identity and SSO
│
├── media/
│   ├── immich/           (has its own Postgres)
│   ├── jellyfin/
│   ├── peertube/
│   ├── audiobookshelf/
│   ├── kavita/
│   └── navidrome/
│
├── gaming/
│   └── veloren/
│
├── docs/
│   ├── install-laptop.md
│   ├── local-names.md
│   └── backup-restore.md
│
├── LICENSE
└── README.md
```

Every application folder has the same pieces:

- `compose.yaml`: the Docker Compose configuration.
- `.env.example`: the settings. Copy it to `.env` and edit the values.
- `data/`: created on first start. It holds the app's files and is ignored by git.
- `create-db.sh`: only for apps that use the shared Postgres (Authentik, PeerTube).

Each application has its own Docker Compose configuration, so you can deploy, update and maintain services independently. The real `.env` files are ignored by git, so your passwords and keys are never committed.

## Getting Started

### Requirements

- A laptop, desktop or compatible home machine.
- Debian recommended.
- Docker Engine and the Docker Compose plugin.
- Available storage for application data and personal media.

New to this? Follow the step-by-step guide: **[docs/install-laptop.md](docs/install-laptop.md)**.

### Quick start

**1. Clone the repository and create the shared network (once)**

```bash
git clone https://github.com/mongosaraiva/LapCloud.git
cd LapCloud
docker network create lapcloud
```

**2. Start the shared database**

```bash
cd core/postgres
cp .env.example .env    # then edit .env and set a strong password
docker compose up -d
```

**3. Start Caddy (the proxy)**

```bash
cd ../caddy
cp .env.example .env
docker compose up -d
```

Then make the names work on your devices: [docs/local-names.md](docs/local-names.md).

**4. Start Authentik**

```bash
cd ../authentik
cp .env.example .env    # then edit .env and set the secret key and password
./create-db.sh
docker compose up -d
```

Open `http://auth.lapcloud.lan/` to create the admin user (use the root address, not `/if/flow/initial-setup/`).

**5. Start the apps you want**

```bash
cd ../../media/jellyfin
cp .env.example .env    # then edit .env (for example MEDIA_DIR)
docker compose up -d
```

Repeat for any other application. The table in [docs/install-laptop.md](docs/install-laptop.md) lists the extra step each app needs.

### Single Sign-On

See [docs/sso/README.md](docs/sso/README.md). The Immich guide is ready; the other apps will follow.

### Backup

See [docs/backup-restore.md](docs/backup-restore.md).

## Design Principles

- **Laptop First:** Start self-hosting with hardware you already own.
- **Open Source First:** Build on open-source software and technologies.
- **Modular by Design:** Install only the applications you need.
- **Hardware Agnostic:** Support laptops, SBCs, mini PCs and desktops where compatible.
- **Privacy First:** Keep control of your data and infrastructure.
- **Beginner Friendly:** Simple Docker Compose deployments and clear documentation.

## Roadmap

- [X] Establish the core repository structure.
- [X] Prepare Docker Compose configurations.
- [X] Implement persistent storage and volume management.
- [X] Deploy Authentik for centralized identity.
- [X] Integrate Immich and Jellyfin.
- [X] Integrate PeerTube.
- [X] Integrate Audiobookshelf, Kavita and Navidrome.
- [X] Add Veloren dedicated server.
- [X] Document laptop installation.
- [ ] Document Single Sign-On (SSO) setup for each app. Done so far: Immich, Audiobookshelf, Jellyfin. Kavita needs HTTPS first.
- [ ] Add HTTPS support (needed for Kavita SSO and for internet access).
- [ ] Test Raspberry Pi and other ARM-based SBC deployments.
- [ ] Validate desktop and mini PC deployments.
- [X] Document backup and restore procedures.
- [ ] Improve security and resource optimization.

## Contributing

LapCloud is an open-source project. Contributions, suggestions, documentation improvements and testing are welcome.

Whether you are a beginner exploring Docker or an experienced self-hosting enthusiast, you are welcome to contribute.

## License

See [LICENSE](LICENSE) for licensing information.

---

<p align="center">
  <strong>LapCloud</strong><br>
  Take back your data. Own your cloud.
</p>
