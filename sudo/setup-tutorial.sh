#!/bin/bash

# Sign the tutorial script
echo "" >> /challenge/.signature    # Ensure there's a newline
echo "/mnt/sudo/run-tutorial" >> /challenge/.signature
echo "/mnt/sudo/run-card" >> /challenge/.signature
echo "/challenge/tutorial" >> /challenge/.signature
echo "/challenge/card" >> /challenge/.signature

# Alias for users
ln -s /mnt/sudo/run-tutorial /challenge/tutorial
ln -s /mnt/sudo/run-card /challenge/card

# Setup bashrc to run tutorial on user login
echo '/mnt/sudo/run-tutorial' >> /etc/bash.bashrc
ln -s /etc/bash.bashrc /etc/bashrc
