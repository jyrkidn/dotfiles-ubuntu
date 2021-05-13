#!/bin/bash

# The source path to backup. Can be local or remote.
SOURCE="$HOME/web $HOME/.ssh $HOME/.dotfiles $HOME/Documents $HOME/Pictures"
# Where to store the incremental backups
DESTBASE="/media/plex/laima"
SSH_SERVER=192.168.0.195

# Where to store today's backup
DEST="$DESTBASE/$(date +%Y-%m-%d)"

# Where to find yesterday's backup
YESTERDAY="$DESTBASE/$(date -d yesterday +%Y-%m-%d)/"

OPTS="--exclude=node_modules --exclude=vendor --exclude=Plugin --exclude=Vendor"

# Use yesterday's backup as the incremental base if it exists
if ssh $SSH_SERVER "[ -d $YESTERDAY ]"
then
    OPTS+=" --link-dest $YESTERDAY"
fi

# Run the rsync
rsync -av $OPTS $SOURCE "$SSH_SERVER:$DEST"

