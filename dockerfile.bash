#!/bin/bash

pushd /tmp
git clone https://github.com/demers/docker-ubuntu.git
popd

cp -f /tmp/docker-ubuntu/Dockerfile .
cp -f /tmp/docker-ubuntu/extra.vimrc .
cp -f /tmp/docker-ubuntu/after.vimrc .
rm -f -r /tmp/docker-ubuntu

sed -i 's/PROJECTNAME=UBUNTU/PROJECTNAME=AI/g' Dockerfile

AJOUTER_ICI=$(cat Dockerfile.after)

sed -i -e '/# AJOUTER_ICI/r Dockerfile.after' Dockerfile

#sed -i "s/# AJOUTER_ICI/$AJOUTER_ICI/g" Dockerfile