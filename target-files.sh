#!/bin/bash

# Check if device argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 device"
    exit 1
fi

device=$1

# Check if old file exists
old_file=~/target-files/"$device"/pixys_"$device"-target_files-new.zip
if [ -f "$old_file" ]; then
    mv "$old_file" ~/target-files/"$device"/pixys_"$device"-target_files-old.zip
else
    echo "Old file not found: $old_file"
    exit 1
fi

# Check if new file exists
new_file=out/target/product/"$device"/pixys_"$device"-target_files.zip
if [ -f "$new_file" ]; then
    cp "$new_file" ~/target-files/"$device"/pixys_"$device"-target_files-new.zip
else
    echo "New file not found: $new_file"
    exit 1
fi

echo "Files successfully renamed and copied."
