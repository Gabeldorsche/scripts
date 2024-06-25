#!/bin/bash

# Check if the device argument is provided
if [ -z "$1" ]; then
    echo "Usage: delta <device>"
    exit 1
fi

# Assign the device name provided as the first argument
device="$1"

# Define the output file name with the correct date syntax
output_file=~/downloads/delta/PixysOS-v7.3.1-GAPPS-"$device"-OFFICIAL-$(date +"%Y%m%d-%H%M%S").zip

# Execute the command with the device name substituted
ota_from_target_files -i ~/target-files/"$device"/pixys_"$device"-target_files-old.zip ~/target-files/"$device"/pixys_"$device"-target_files-new.zip "$output_file"

# Check if the ota_from_target_files command was successful
if [ $? -eq 0 ]; then
    # Execute the json.sh script with the generated file
    ./json.sh "$output_file"
else
    echo "Failed to generate delta file"
    exit 1
fi

