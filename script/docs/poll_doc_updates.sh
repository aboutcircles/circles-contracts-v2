#!/bin/bash

cd /root/circles-contracts-v2/
git fetch origin docs-v0.3.4

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ $LOCAL != $REMOTE ]; then
    git pull origin docs-v0.3.4
    systemctl restart forge-doc
fi
