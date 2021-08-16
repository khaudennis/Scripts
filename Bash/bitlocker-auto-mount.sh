#!/bin/bash

### WORK IN PROGRESS 

if [[ "$EUID" != 0 ]]; then
    echo "Please run as root."
else
    blkid | grep BitLocker | awk "{ print $1 }" | tr -d : | xargs -I % sh -c "dislocker -V % -u{password} -- /bitlocker/{id}"
fi