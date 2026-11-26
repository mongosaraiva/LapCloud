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

| Application | Description |
|---|---|
| [Authentik](https://goauthentik.io/) | Identity management and Single Sign-On (SSO) |

### Media & Entertainment

| Application | Description |
|---|---|
| [Immich](https://immich.app/) | Self-hosted photo and video management |
| [Jellyfin](https://jellyfin.org/) | Movies, TV shows and media streaming |
| [PeerTube](https://joinpeertube.org/) | Decentralized video hosting and sharing |
| [Audiobookshelf](https://www.audiobookshelf.org/) | Audiobooks and podcast management |
| [Kavita](https://www.kavitareader.com/) | Ebooks, manga, comics and reading |
| [Navidrome](https://www.navidrome.org/) | Personal music streaming server |

### Gaming

| Application | Description |
|---|---|
| [Veloren](https://veloren.net/) | Open-source multiplayer voxel RPG with third-person gameplay |

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

## Repository Structure

```text
LapCloud/
│
├── core/
│   ├── postgres/
│   │   ├── compose.yaml
│   │   └── .env.example
│   └── authentik/
│       ├── compose.yaml
│       ├── .env.example
│       └── create-db.sh
│
├── media/            (planned, not created yet)
│   ├── immich/
│   │   └── compose.yaml
│   ├── jellyfin/
│   │   └── compose.yaml
│   ├── peertube/
│   │   └── compose.yaml
│   ├── audiobookshelf/
│   │   └── compose.yaml
│   ├── kavita/
│   │   └── compose.yaml
│   └── navidrome/
│       └── compose.yaml
│
├── gaming/           (planned, not created yet)
│   └── veloren/
│       └── compose.yaml
│
├── LICENSE
└── README.md
```

Each application has its own Docker Compose configuration, allowing users to deploy, update and maintain services independently.

Each application also has its own `.env.example`. To configure an app, go to its folder, copy it to `.env` and edit the values:

```bash
cp .env.example .env
```

The real `.env` files are ignored by git, so your passwords and keys are never committed. Folders marked as planned will follow the same pattern when they are added.

## Getting Started

### Requirements

- A laptop, desktop or compatible home machine.
- Debian recommended.
- Docker Engine.
- Docker Compose plugin.
- Available storage for application data and personal media.

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/mongosaraiva/LapCloud.git
cd LapCloud
```

**2. Create the shared network (once)**

```bash
docker network create lapcloud
```

**3. Start the shared database**

```bash
cd core/postgres
cp .env.example .env    # then edit .env and set a strong password
docker compose up -d
```

**4. Start Authentik**

```bash
cd ../authentik
cp .env.example .env    # then edit .env and set the secret key and password
./create-db.sh
docker compose up -d
```

Open `http://<your-ip>:9000/if/flow/initial-setup/` to create the admin user.

Repeat for any other application you want to deploy.

*Installation instructions and configuration examples will be documented individually for each service.*

## Design Principles

- **Laptop First:** Start self-hosting with hardware you already own.
- **Open Source First:** Build on open-source software and technologies.
- **Modular by Design:** Install only the applications you need.
- **Hardware Agnostic:** Support laptops, SBCs, mini PCs and desktops where compatible.
- **Privacy First:** Keep control of your data and infrastructure.
- **Beginner Friendly:** Simple Docker Compose deployments and clear documentation.

## Roadmap

- [X] Establish the core repository structure.
- [ ] Prepare Docker Compose configurations.
- [ ] Implement persistent storage and volume management.
- [ ] Deploy Authentik for centralized identity.
- [ ] Integrate Immich and Jellyfin.
- [ ] Integrate PeerTube.
- [ ] Integrate Audiobookshelf, Kavita and Navidrome.
- [ ] Add Veloren dedicated server.
- [ ] Document laptop installation.
- [ ] Test Raspberry Pi and other ARM-based SBC deployments.
- [ ] Validate desktop and mini PC deployments.
- [ ] Document backup and restore procedures.
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
