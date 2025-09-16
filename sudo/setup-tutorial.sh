#!/bin/bash

# Sign the tutorial script
echo "/mnt/sudo/run-tutorial" >> /challenge/.signature
ln -s /mnt/sudo/run-tutorial /challenge/tutorial

# Setup bashrc to run tutorial on user login
echo '/mnt/sudo/run-tutorial' >> /etc/bash.bashrc
ln -s /etc/bash.bashrc /etc/bashrc
