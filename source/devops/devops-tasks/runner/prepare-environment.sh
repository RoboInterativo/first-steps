#!/bin/bash
apt update && apt install -y git openssh-client
ssh-keyscan mds-gitlab.baum.ru >> ~/.ssh/known_hosts
