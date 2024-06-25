#!/usr/bin/env bash

# A github script to push all repositories from a manifest

# This again, will have to be adapted based on your setup.

cwd=$PWD
PROJECTS="$(grep 'pixys' .repo/manifests/pixys.xml | awk '{print $2}' | awk -F'"' '{print $2}' | uniq | grep -v caf)"
for project in ${PROJECTS}; do
    cd "$project" || exit
    git push git@github.com:PixysOS/"$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')".git HEAD:refs/heads/fourteen-v3
    cd - || exit
done
cd "$cwd" || exit
