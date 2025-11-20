# Weewx Zabbix Monitoring Setup

This directory contains Zabbix monitoring configuration for the weewx weather station running in Docker containers.

## Overview

This monitoring setup provides comprehensive health checks for the weewx weather station deployment:

1. **Website Health Check** - Verifies the website is accessible and displaying current data
2. **Container Status Monitoring** - Checks if weewx and nginx containers are running
3. **Data Freshness Check** - Ensures weather data graphs are being updated regularly

## Components

### Scripts

- `weewx_website_health.sh` - Checks https://weewx.kozik.net for correct content and timestamp freshness
- `weewx_data_freshness.sh` - Monitors the age of PNG graph files in data/public_html

### Configuration

- `weewx.conf` - Zabbix UserParameter definitions for all monitoring checks

## Requirements

- Zabbix Agent v1 (zabbix-agentd) version 7.4 or later
- Docker (containers must be accessible to zabbix user)
- Access to /home/jkozik/weewx51/data/public_html directory
- curl command available

## Installation Instructions

### 1. Install Zabbix Agent

If not already installed, follow the Zabbix 7.4 installation guide for Ubuntu 24.04.

### 2. Install Monitoring Scripts

```bash
# Create scripts directory
sudo mkdir -p /etc/zabbix/scripts

# Copy monitoring scripts
sudo cp weewx_website_health.sh /etc/zabbix/scripts/
sudo cp weewx_data_freshness.sh /etc/zabbix/scripts/

# Set permissions
sudo chmod 755 /etc/zabbix/scripts/weewx_website_health.sh
sudo chmod 755 /etc/zabbix/scripts/weewx_data_freshness.sh
sudo chown zabbix:zabbix /etc/zabbix/scripts/weewx_*.sh
```

### 3. Install UserParameter Configuration

```bash
# Copy UserParameter config
sudo cp weewx.conf /etc/zabbix/zabbix_agentd.d/

# Set permissions
sudo chmod 644 /etc/zabbix/zabbix_agentd.d/weewx.conf
sudo chown root:root /etc/zabbix/zabbix_agentd.d/weewx.conf
```

### 4. Configure Permissions

The zabbix user needs access to Docker and the weewx data directory:

```bash
# Add zabbix user to docker group (for container monitoring)
sudo usermod -aG docker zabbix

# Add zabbix user to jkozik group (for data directory access)
sudo usermod -aG jkozik zabbix

# Allow group traversal of home directory
chmod g+x /home/jkozik

# Restart zabbix-agent
sudo systemctl restart zabbix-agent
```

### 5. Test UserParameters

Verify all UserParameters are working:

```bash
# Test website health check
zabbix_agentd -t weewx.website.health

# Test container status
zabbix_agentd -t weewx.container.status[weewx]
zabbix_agentd -t weewx.container.status[nginx]

# Test data freshness
zabbix_agentd -t weewx.data.freshness
```

Expected outputs:
- `weewx.website.health`: 0-3 (0=healthy, 1=banner missing, 2=stale timestamp, 3=unreachable)
- `weewx.container.status[*]`: 0 or 1 (0=stopped, 1=running)
- `weewx.data.freshness`: number of minutes since last data update

## Zabbix Server Configuration

### Items to Create

Create these items on the Zabbix server for the weewx174.kozik.net host:

#### 1. Website Health Check
- **Name:** Weewx Website Health
- **Type:** Zabbix agent
- **Key:** `weewx.website.health`
- **Type of information:** Numeric (unsigned)
- **Update interval:** 5m
- **Value mapping:**
  - 0 → Healthy
  - 1 → Banner Missing
  - 2 → Timestamp Stale
  - 3 → Unreachable

#### 2. Weewx Container Status
- **Name:** Weewx Container Status
- **Type:** Zabbix agent
- **Key:** `weewx.container.status[weewx]`
- **Type of information:** Numeric (unsigned)
- **Update interval:** 1m
- **Value mapping:**
  - 0 → Stopped
  - 1 → Running

#### 3. Nginx Container Status
- **Name:** Nginx Container Status
- **Type:** Zabbix agent
- **Key:** `weewx.container.status[nginx]`
- **Type of information:** Numeric (unsigned)
- **Update interval:** 1m
- **Value mapping:**
  - 0 → Stopped
  - 1 → Running

#### 4. Data Freshness
- **Name:** Weewx Data Age (minutes)
- **Type:** Zabbix agent
- **Key:** `weewx.data.freshness`
- **Type of information:** Numeric (unsigned)
- **Update interval:** 5m
- **Units:** minutes

### Triggers to Create

#### 1. Website Unhealthy
- **Name:** Weewx website is unhealthy
- **Severity:** High
- **Expression:** `last(/weewx174.kozik.net/weewx.website.health) <> 0`
- **Description:** Weewx website is unhealthy (value: {ITEM.LASTVALUE})

#### 2. Weewx Container Down
- **Name:** Weewx container is not running
- **Severity:** High
- **Expression:** `last(/weewx174.kozik.net/weewx.container.status[weewx]) = 0`
- **Description:** Weewx container has stopped

#### 3. Nginx Container Down
- **Name:** Nginx container is not running
- **Severity:** High
- **Expression:** `last(/weewx174.kozik.net/weewx.container.status[nginx]) = 0`
- **Description:** Nginx web server container has stopped

#### 4. Data is Stale
- **Name:** Weewx data is stale
- **Severity:** Warning
- **Expression:** `last(/weewx174.kozik.net/weewx.data.freshness) > 10`
- **Description:** Weewx data hasn't been updated in {ITEM.LASTVALUE} minutes

## Important Configuration Notes

### Timezone Considerations

**Critical:** The website health check script must account for timezone differences between the server and weewx.

- **Server timezone:** The monitoring server typically runs in UTC
- **Weewx timezone:** Configured in docker-compose.yml as `TZ=America/Chicago` (CST)
- **Website timestamps:** Displayed in weewx's timezone (CST), not UTC

The `weewx_website_health.sh` script handles this by parsing timestamps with the correct timezone:
```bash
TIMESTAMP_EPOCH=$(TZ="America/Chicago" date -d "$TIMESTAMP" +%s 2>/dev/null)
```

**If you change the weewx timezone** in docker-compose.yml, you must also update the timezone in the health check script to match, or you'll get false positives for stale timestamps.

**Example scenarios:**
- Weewx shows "10:00:00 CST" on the website
- Server time is "16:00:00 UTC" (same moment, different timezone)
- Without timezone handling, the script would incorrectly calculate a 6-hour age difference
- With proper timezone handling, it correctly identifies them as the same time

## Troubleshooting

### Permission Denied Errors

**Docker socket permission denied:**
```bash
sudo usermod -aG docker zabbix
sudo systemctl restart zabbix-agent
```

**Cannot access data directory:**
```bash
sudo usermod -aG jkozik zabbix
chmod g+x /home/jkozik
sudo systemctl restart zabbix-agent
```

### UserParameter Not Found

Check that the config file is loaded:
```bash
grep -r "weewx" /etc/zabbix/zabbix_agentd.d/
sudo systemctl restart zabbix-agent
```

### Script Returns Unexpected Values

Test scripts manually as zabbix user:
```bash
sudo -u zabbix /etc/zabbix/scripts/weewx_website_health.sh
sudo -u zabbix /etc/zabbix/scripts/weewx_data_freshness.sh
```

## Monitoring Logic

### Website Health Check (weewx_website_health.sh)

This script performs the following checks:

1. Fetches https://weewx.kozik.net
2. Verifies "weewx.kozik.net" banner is present
3. Extracts timestamp from `<p class="lastupdate">` tag
4. Parses timestamp using America/Chicago timezone (to match weewx's TZ setting)
5. Calculates timestamp age against current time
6. Returns status code based on findings

**Return codes:**
- `0` = Website healthy (banner present, timestamp fresh)
- `1` = Banner missing from page
- `2` = Timestamp missing or older than 10 minutes
- `3` = Website unreachable

**Note:** The script explicitly uses `TZ="America/Chicago"` when parsing timestamps to match the timezone configured in weewx's docker-compose.yml. If you change weewx's timezone, update the script accordingly.

### Data Freshness Check (weewx_data_freshness.sh)

This script:

1. Finds all PNG files in `/home/jkozik/weewx51/data/public_html`
2. Identifies the newest file by modification time
3. Calculates age in minutes
4. Returns the age value

**Return value:**
- `0-999` = Age in minutes of newest PNG file
- `999` = No files found (error condition)

### Container Status Check

Uses docker ps to check container state:
```bash
docker ps --filter "name=<container>" --format "{{.State}}" | grep -c "running"
```

**Return value:**
- `1` = Container is running
- `0` = Container is stopped or missing

## Notes

- The website health check has a 10-minute staleness threshold, matching typical weewx update intervals
- Container checks run every minute for quick detection of failures
- Data freshness checks run every 5 minutes to balance responsiveness and overhead
- All scripts are designed to be non-intrusive and have minimal performance impact

## Version History

- **2025-11-20** - Initial version with website health, container status, and data freshness monitoring
  - Fixed timezone handling in website health check to properly parse CST timestamps on UTC server

## Author

Created for weewx.kozik.net monitoring using Zabbix 7.4
