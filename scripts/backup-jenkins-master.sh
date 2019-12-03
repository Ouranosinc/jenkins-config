#!/bin/sh -x
# Backup to /tmp/jenkins_master_home_$JENKINS_MASTER_PORT.tgz with default values.

cd `dirname "$0"`/..
. ./env.local

if [ -z "$BACKUP_OUT_DIR" ]; then
    BACKUP_OUT_DIR=/tmp
fi

if [ -z "$DOCKER_USER_PERSISTENCE_VOLUME" ]; then
    # dupe with jenkins-compose.sh
    DOCKER_USER_PERSISTENCE_VOLUME=jenkins_master_home_$JENKINS_MASTER_PORT
fi

scripts/backup-datavolume.sh "$DOCKER_USER_PERSISTENCE_VOLUME" "$BACKUP_OUT_DIR"

ls -lh $BACKUP_OUT_DIR/$DOCKER_USER_PERSISTENCE_VOLUME.tgz


# vi: tabstop=8 expandtab shiftwidth=4 softtabstop=4
