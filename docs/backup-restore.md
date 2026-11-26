# Backup and restore

Your data lives in two places:

1. **Databases** (Postgres). Do not copy these files while the database is running. Make a dump instead.
2. **Files** in each app's `data/` folder, plus your media folders and your `.env` files.

Keep backups on a different disk than the one running LapCloud.

```bash
mkdir -p backups
```

The `backups/` folder is ignored by git.

## 1. Back up the shared Postgres (Authentik, PeerTube)

```bash
docker exec lapcloud-postgres pg_dumpall -U admin | gzip > backups/postgres-$(date +%F).sql.gz
```

Use the user name from `core/postgres/.env` if you changed it.

## 2. Back up the Immich database

Immich has its own Postgres. This is the dump command recommended by the Immich project:

```bash
docker exec lapcloud-immich-postgres pg_dumpall --clean --if-exists --username=postgres | gzip > backups/immich-db-$(date +%F).sql.gz
```

## 3. Back up the files

Stop the apps first, so the files are not changing while you copy them. Containers create files as `root`, so use `sudo`:

```bash
sudo tar -czf backups/lapcloud-files-$(date +%F).tar.gz \
  --exclude='data/postgres' \
  core/*/data core/*/.env media/*/data media/*/.env gaming/*/data gaming/*/.env
```

Why exclude `data/postgres`? Those are the live database files. You already have the dumps above, which are safe to restore.

If you pointed `UPLOAD_LOCATION`, `MEDIA_DIR` or the other `*_DIR` variables to folders outside the repository, back those folders up too. They can be very large, so `rsync` to another disk is usually better than `tar`:

```bash
rsync -a /mnt/photos/ /mnt/backup-disk/photos/
```

## Restore the shared Postgres

1. Start only Postgres, with a new, empty `data/` folder:

```bash
cd core/postgres
docker compose up -d
```

2. Load the dump:

```bash
gunzip -c ../../backups/postgres-2026-01-01.sql.gz | docker exec -i lapcloud-postgres psql -U admin -d postgres -q
```

You will see messages such as `role "admin" already exists`. They are harmless: the new Postgres already has that user.

3. Start the apps again. They find their databases and users as before.

## Restore the files

Put the files back in the same folders, as `root`:

```bash
sudo tar -xzf backups/lapcloud-files-2026-01-01.tar.gz
```

## Restore the Immich database

Follow the Immich documentation for restoring a database dump. Use the same container name, `lapcloud-immich-postgres`.

## What was tested

- Shared Postgres: dump, delete the data folder, start a new Postgres and restore. The data came back.
- Not tested yet: the Immich database restore and the `tar` backup of the file folders.

## Check your backups

A backup you never restored is only a hope. Once in a while, restore it on a spare machine or in a test folder.
