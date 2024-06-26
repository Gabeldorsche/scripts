#!/usr/bin/env bash
# Copyright (C) 2016-2018 The Dirty Unicorns project
# Copyright (C) 2016 Jacob McSwain
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The source directory; this is automatically two folder up because the script
# is located in vendor/du/scripts. Other ROMs will need to change this. The logic is
# as follows:
# 1. Get the absolute path of the script with readlink in case there is a symlink
#    This script may be symlinked by a manifest so we need to account for that
# 2. Get the folder containing the script with dirname
# 3. Move into the folder that is two folder above that one and print it
WORKING_DIR=~/pixys-qpr3

# The tag you want to merge in goes here
BRANCH=android-14.0.0_r50

# Google source url
REPO=https://android.googlesource.com/platform/

# This is the array of upstream repos we track
upstream=()

# This is the array of repos with merge errors
failed=()

# This is the array of repos to blacklist and not merge
blacklist=('hardware/qcom/*' 'packages/apps/Updater' 'prebuilts/clang/host/linux-x86' 'prebuilts/module_sdk' 'vendor/*' '.repo/manifests' 'platform/manifest' 'frameworks/base')

# Colors
COLOR_RED='\033[0;31m'
COLOR_BLANK='\033[0m'

function is_in_blacklist() {
  for repo in ${blacklist[@]}
    do
      if [ "$repo" == "$1" ]; then
        return 0;
      fi
  done
  return 1;
}

function warn_user() {
  echo "Using this script may cause you to lose unsaved work"
  read -r -p "Do you want to continue? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "You've been warned"
  else
    exit 1
  fi
}

function get_repos() {
  declare -a repos=( $(repo list | cut -d: -f1) )
  curl --output /tmp/rebase.tmp $REPO --silent # Download the html source of the Android source page
  # Since their projects are listed, we can grep for them
  for i in ${repos[@]}
  do
    if grep -q "$i" /tmp/rebase.tmp; then # If Google has it and
      if grep -q "$i" $WORKING_DIR/.repo/manifests/snippets/pixys.xml; then # If we have it in our manifest and
        if grep "$i" $WORKING_DIR/.repo/manifests/snippets/pixys.xml | grep -q "remote="; then # If we track our own copy of it
          if ! is_in_blacklist $i; then # If it's not in our blacklist
            upstream+=("$i") # Then we need to update it
          else
            echo "$i is in blacklist"
          fi
        fi
      fi
    fi
  done
  rm /tmp/rebase.tmp
}

function delete_upstream() {
  for i in ${upstream[@]}
  do
    rm -rf $i
  done
}

function merge() {
  cd $WORKING_DIR/$1
  git pull $REPO/$1.git -t $BRANCH --signoff
  if [ $? -ne 0 ]; then # If merge failed
    failed+=($1) # Add to the list
  fi
}

function print_result() {
  if [ ${#failed[@]} -eq 0 ]; then
    echo ""
    echo "========== "$BRANCH" is merged sucessfully =========="
    echo "========= Compile and test before pushing to github ========="
    echo ""
  else
    echo -e $COLOR_RED
    echo -e "These repos have merge errors: \n"
    for i in ${failed[@]}
    do
      echo -e "$i"
    done
    echo -e $COLOR_BLANK
  fi
}

# Start working
cd $WORKING_DIR

# Warn user that this may destroy unsaved work
# warn_user

# Get the upstream repos we track
get_repos

# Merge every repo in upstream
for i in ${upstream[@]}
do
  merge $i
done

# Go back home
cd $WORKING_DIR

# Print any repos that failed, so we can fix merge issues
print_result
