#!/bin/bash

# re-generate ssh keys after boot
# this file is executed before ssh.service,
# so there's no need to re-start sshd after the re-generation
rm -rf /etc/ssh/ssh_host* && ssh-keygen -A

# add any custom init code here
