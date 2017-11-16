#!/usr/bin/env bash
echo export PATH=\$PATH:`go env | grep GOPATH | awk -F= '{print $2}' | tr -d \"`/bin > /etc/profile.d/go_bin.sh && source /etc/profile

# Effective immediately
mkdir -p ~/bin
cd ~/bin
ln -s ../go/bin/* .

