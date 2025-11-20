#!/bin/bash
# Weewx Website Health Check
# Returns: 0=healthy, 1=banner missing, 2=timestamp stale/missing, 3=unreachable

URL="https://weewx.kozik.net"
MAX_AGE_MINUTES=10

# Fetch the website
CONTENT=$(curl -s -m 10 "$URL" 2>/dev/null)

# Check if curl succeeded
if [ $? -ne 0 ] || [ -z "$CONTENT" ]; then
    echo 3
    exit 0
fi

# Check for banner
if ! echo "$CONTENT" | grep -q "weewx.kozik.net"; then
    echo 1
    exit 0
fi

# Extract timestamp from <p class="lastupdate">MM/DD/YY HH:MM:SS</p>
TIMESTAMP=$(echo "$CONTENT" | grep -oP '(?<=<p class="lastupdate">)[^<]+' | head -1)

if [ -z "$TIMESTAMP" ]; then
    echo 2
    exit 0
fi

# Parse timestamp (format: MM/DD/YY HH:MM:SS)
# Convert to epoch time for comparison (timestamp is in America/Chicago timezone)
TIMESTAMP_EPOCH=$(TZ="America/Chicago" date -d "$TIMESTAMP" +%s 2>/dev/null)

if [ $? -ne 0 ]; then
    echo 2
    exit 0
fi

# Get current time
CURRENT_EPOCH=$(date +%s)

# Calculate age in minutes
AGE_MINUTES=$(( (CURRENT_EPOCH - TIMESTAMP_EPOCH) / 60 ))

# Check if timestamp is stale (older than MAX_AGE_MINUTES)
if [ $AGE_MINUTES -gt $MAX_AGE_MINUTES ]; then
    echo 2
    exit 0
fi

# All checks passed
echo 0
