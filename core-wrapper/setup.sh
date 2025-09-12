#!/bin/bash

# Setup the core-wrapper environment
chown root:root /mnt/core-wrapper/wrapper
chmod 4755 /mnt/core-wrapper/wrapper
ln -s /mnt/core-wrapper/wrapper /tutorial

# Setup bashrc to source core-wrapper bashrc on user login
echo 'source /mnt/core-wrapper/.bashrc' >> /etc/bash.bashrc
ln -s /etc/bash.bashrc /etc/bashrc
