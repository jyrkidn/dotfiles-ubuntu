#!/bin/bash

DATE=`date +%Y%m%d`
rsync -avzh ~/web ~/.ssh ~/.dotfiles ~/Documents ~/Pictures --exclude=node_modules --exclude=vendor 192.168.0.195:/media/plex/laima/$DATE/

