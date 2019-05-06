# backup-server
Docker based ssh backup host with `borg` and `restic` installed. Can be effectively used for as a backup repository and a tool to backup containers.

## Run a backup host and backup a client with `borg`

Run the backup host with this command:

    docker run -d \
        --restart always \
        --port 22:22 \
        --volume /mnt/backup:/bkup \
        --name backup \
        amdavidson/backup:latest

Add your ssh key to the host:

    docker cp id_rsa.pub backup:/bkup/.ssh/authorized_keys
    docker run --volumes-from backup amdavidson/backup-server chown 1111:1111 /bkup/.ssh/authorized_keys


Create a repository for backups:

    borg init backup:/bkup/client-name

Periodically run a backup with a command similar to this:

    borg create --stats --verbose backup:/bkup/client-name::$(date '+%s') ~/

## Backup a container remotely with `restic`

Create a repository for backups:

    docker run \
        --rm \
        --volumes-from backup \
        --env RESTIC_PASSWORD=secretpw \
        --env AWS_ACCESS_KEY_ID=asvc0832n20vasfdh0 \
        --env AWS_SECRET_ACCESS_KEY=aokjsvdn0e2nc08va80428b308jcwa08je02983jr032 \
        amdavidson/backup-server \
        restic -r s3:s3.wasabisys.com/other-container init

Perodically run a backup with a command similar to this:

    docker run \
        --rm \
        --volumes-from backup \
        --volumes-from other-container:ro \
        --env RESTIC_PASSWORD=secretpw \
        --env AWS_ACCESS_KEY_ID=asvc0832n20vasfdh0 \
        --env AWS_SECRET_ACCESS_KEY=aokjsvdn0e2nc08va80428b308jcwa08je02983jr032 \
        amdavidson/backup-server \
        restic -r s3:s3.wasabisys.com/other-container backup /data

## Backup a container locally with `borg`

Create a repository for backups:

    docker run \
        --rm \
        --volumes-from backup \
        amdavidson/backup-server \
        borg init /bkup/other-container

Periodically run a backup with a command similar to this:

    docker run \
        --rm \
        --volumes-from backup \
        --volumes-from other-container:ro \
        amdavidson/backup-server \
        borg create --verbose --stats /bkup/other-container::$(date '+%s') /data



