#!/bin/bash
# Weewx Data Freshness Check
# Returns: age in minutes of the newest PNG file in public_html

DATA_DIR="/home/jkozik/weewx51/data/public_html"

# Find the newest PNG file's timestamp
NEWEST_FILE=$(find "$DATA_DIR" -name "*.png" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)

# Check if we found any files
if [ -z "$NEWEST_FILE" ]; then
    # No files found, return a large number (999)
    echo 999
    exit 0
fi

# Get current time
CURRENT_TIME=$(date +%s)

# Calculate age in minutes (use integer division)
AGE_MINUTES=$(( (CURRENT_TIME - ${NEWEST_FILE%.*}) / 60 ))

echo "$AGE_MINUTES"
