# weewx51
Setup weewx51 in docker compose environment using the image [felddy/weewx](https://hub.docker.com/r/felddy/weewx) created from the [weewx-docker](https://github.com/felddy/weewx-docker) repository by [felddy](https://github.com/felddy).  I had been on weewx 4.5 and have been monitoring weather using weewx since 2018.  As part of this upgrade, I am carrying my data forward to run under 5.1.

My past weewx servers have been container based and felddy's appears to be one of the most current ones based on a pip install python installation.  

## Clone repository

```
(weewx-venv) jkozik@weewx174:~$ git clone https://github.com/jkozik/weewx51.git
Cloning into 'weewx51'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
Receiving objects: 100% (3/3), done.
(weewx-venv) jkozik@weewx174:~$ cd weewx51a
```
Make sure some key directories are setup with the correct permissions
```
jkozik@weewx174:~/weewx51$ mkdir -p data data/public_html data/archive
jkozik@weewx174:~/weewx51$ ls -lasth data
total 16K
4.0K drwxrwxr-x 4 jkozik jkozik 4.0K Apr 14 19:45 .
4.0K drwxrwxr-x 4 jkozik jkozik 4.0K Apr 14 19:45 ..
4.0K drwxrwxr-x 2 jkozik jkozik 4.0K Apr 14 19:45 archive
4.0K drwxrwxr-x 2 jkozik jkozik 4.0K Apr 14 19:45 public_html
jkozik@weewx174:~/weewx51$
```
For some reason, the data and data/public_html directories get created by the image with root:root ownership.  That will cause the container to silently fail. 
## run for the first time
```
jkozik@weewx174:~/weewx51$ docker compose run --rm weewx
Creating configuration file /data/weewx.conf
Processing configuration file /data/weewx.conf
Creating directory /data/skins
Copying new skin Ftp into /data/skins/Ftp
Copying new skin Smartphone into /data/skins/Smartphone
Copying new skin Standard into /data/skins/Standard
Copying new skin Rsync into /data/skins/Rsync
Copying new skin Mobile into /data/skins/Mobile
Copying new skin Seasons into /data/skins/Seasons
Copying examples into /data/examples
Creating a new 'user' directory at /data/bin/user
Copying utility files into /data/util
Copying script files into /data/scripts
Saving configuration file /data/weewx.conf
A new set of configurations was created.
Console logging configuration has been appended to /data/weewx.conf.
Please review and update /data/weewx.conf as needed, then restart the container.
jkozik@weewx174:~/weewx51$
```
In the data directory a series of configuration files are created.  Key file weewx.conf.  
This file is configurated to collect weather data from a Simulator. 
```
jkozik@weewx174:~/weewx51$ ls
data  docker-compose.yml  README.md
jkozik@weewx174:~/weewx51$ cd data
jkozik@weewx174:~/weewx51/data$ ls
bin  examples  scripts  skins  util  weewx.conf
jkozik@weewx174:~/weewx51/data$ grep Sim weewx.conf
    station_type = Simulator
[Simulator]
jkozik@weewx174:~/weewx51/data$
```
For testing purposes, it is sometimes useful to run (`docker compose up -d`) this setup to verify basic sanity.  I did, but it should not be necessary.
## Provision Vantage ethernet Station
The next step is to add parameters to the weewx.conf file for the weather station.  I use a [Davis Weather Envoy](https://www.scientificsales.com/6316-Davis-Wireless-Weather-Envoy-p/6316.htm?gclid=CjwKCAjwwe2_BhBEEiwAM1I7sUqtemh_VCxJFZfFE7lrgrObZEbqgizOSP3DZ1AnnjQzEtGmnZtgeRoCsZAQAvD_BwE&utm_source=google&gad_source=1&utm_medium=cpc&gbraid=0AAAAAD_uBLTSudUJZEgUi9t3C3L2hvb6V&utm_campaign=GSNFree) that links to a [Vantage Pro2](https://www.davisinstruments.com/collections/vantage-pro2) weather station.   The Envoy is equipped with an ethernet interface from [WiFiLogger2 Data Logger for Davis Pro2](https://www.scaledinstruments.com/shop/shop-by-category/data-loggers/wifilogger2/?gad_source=1&gbraid=0AAAAADqH46sSLTnO0H3QzB-fwqdYVEOy3&gclid=CjwKCAjwwe2_BhBEEiwAM1I7sW6KwkobWYJ9mxrRxw9zDneEO-AFp8gQDAW74wuircqwdkyDDI1iVBoC6WcQAvD_BwE). I used to use the USB interface, but I found it troublesome when hosting in a container enviroment.  

I provisioning requires station specific information.
```

jkozik@weewx174:~/weewx51$ docker compose run --rm weewx station reconfigure
Using configuration file /data/weewx.conf
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Initializing weectl version 5.1.0
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Command line: /opt/venv/bin/weectl station reconfigure --config /data/weewx.conf
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Using Python: 3.13.0 (main, Dec  3 2024, 02:26:48) [GCC 12.2.0]
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Located at:   /opt/venv/bin/python
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Platform:     Linux-6.8.0-57-generic-x86_64-with-glibc2.36
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Locale:       'LC_CTYPE=C.UTF-8;LC_NUMERIC=C;LC_TIME=C;LC_COLLATE=C;LC_MONETARY=C;LC_MESSAGES=C;LC_PAPER=C;LC_NAME=C;LC_ADDRESS=C;LC_TELEPHONE=C;LC_MEASUREMENT=C;LC_IDENTIFICATION=C'
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Entry path:   /opt/venv/bin/weectl
2025-04-13 19:38:32 weectl[6]: INFO weectllib: WEEWX_ROOT:   /data
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Config file:  /data/weewx.conf
2025-04-13 19:38:32 weectl[6]: INFO weectllib: User module:  /data/bin/user
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Debug:        0
2025-04-13 19:38:32 weectl[6]: INFO weectllib: User:         weewx
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Group:        weewx
2025-04-13 19:38:32 weectl[6]: INFO weectllib: Groups:       weewx
Processing configuration file /data/weewx.conf

Give a description of the station. This will be used for the title of reports.
description [WeeWX station]: weewx.kozik.net

Specify altitude, with units 'foot' or 'meter'.  For example:
  35, foot
  12, meter
altitude [0, foot]: 781, foot

Specify latitude in decimal degrees, negative for south.
latitude [0.0]: 41.7900009
Specify longitude in decimal degrees, negative for west.
longitude [0.0]: -88.1200027

Choose a unit system for the reports. Later, you can modify
your choice, or choose a combination of units. Unit systems
include:
  us         (ºF, inHg, in, mph)
  metricwx   (ºC, mbar, mm, m/s)
  metric     (ºC, mbar, cm, km/h)
unit system [us]:

Choose a driver. Installed drivers include:
  0) AcuRite         (weewx.drivers.acurite)
  1) CC3000          (weewx.drivers.cc3000)
  2) FineOffsetUSB   (weewx.drivers.fousb)
  3) Simulator       (weewx.drivers.simulator)
  4) TE923           (weewx.drivers.te923)
  5) Ultimeter       (weewx.drivers.ultimeter)
  6) Vantage         (weewx.drivers.vantage)
  7) WMR100          (weewx.drivers.wmr100)
  8) WMR300          (weewx.drivers.wmr300)
  9) WMR9x8          (weewx.drivers.wmr9x8)
 10) WS1             (weewx.drivers.ws1)
 11) WS23xx          (weewx.drivers.ws23xx)
 12) WS28xx          (weewx.drivers.ws28xx)
driver [3]: 6
2025-04-13 19:41:24 weectl[6]: INFO weectl-station: Using Vantage version 3.6.2 (None)
Specify the hardware interface, either 'serial' or 'ethernet'.
If the station is connected by serial, USB, or serial-to-USB
adapter, specify serial.  Specify ethernet for stations with
WeatherLinkIP interface.
type [serial]: ethernet
Specify the IP address (e.g., 192.168.0.10) or hostname
(e.g., console or console.example.com) for stations with
an ethernet interface.
host [1.2.3.4]: 192.168.100.123

You can register the station on weewx.com, where it will be included in a
map. If you choose to register, you will also need a unique URL to identify
the station (such as a website, or a WeatherUnderground link).
register this station (y/n)? [n]
Saving configuration file /data/weewx.conf
Saved old configuration file as /data/weewx.conf.20250413194149
jkozik@weewx174:~/weewx51$
```
Note the docker compose command.  If it has parameters after the weewx parameter, the underlying container runs the command weectl.  

Verify that references to Vantage are found in the weewx.conf
```
jkozik@weewx174:~/weewx51$ cd data
jkozik@weewx174:~/weewx51/data$ grep Vantage weewx.conf
    station_type = Vantage
[Vantage]
    # This section is for the Davis Vantage series of weather stations.
    #  serial (the classic VantagePro)
    # Vantage model Type: 1 = Vantage Pro; 2 = Vantage Pro2
jkozik@weewx174:~/weewx51/data$
```
## Verify weewx server can access Davis Weather Envoy
The Davis Weather Envoy is a wireless receiver that talks to the Vantage Pro2 weather station.  My Envoy was previously programmed back when the device used a USB connection.  

Verify that the weewx server can access the contents of the Davis Weather Envoy:
```
jkozik@weewx174:~/weewx51/data$ docker compose run --rm weewx device --info
Using configuration file /data/weewx.conf
Using driver weewx.drivers.vantage.
Using Vantage driver version 3.6.2 (weewx.drivers.vantage)
Unable to wake up console... sleeping
Unable to wake up console... retrying
Querying...
Davis Vantage EEPROM settings:

    CONSOLE TYPE:                   Vantage Pro2

    CONSOLE FIRMWARE:
      Date:                         Dec 30 2008
      Version:                      1.82

    CONSOLE SETTINGS:
      Archive interval:             600 (seconds)
      Altitude:                     781 (foot)
      Wind cup type:                large
      Rain bucket type:             0.01 inches
      Rain year start:              1
      Onboard time:                 2025-04-13 20:04:24

    CONSOLE DISPLAY UNITS:
      Barometer:                    inHg
      Temperature:                  degree_F
      Rain:                         inch
      Wind:                         mile_per_hour

    CONSOLE STATION INFO:
      Latitude (onboard):           +41.8
      Longitude (onboard):          -88.1
      Use manual or auto DST?       AUTO
      DST setting:                  N/A
      Use GMT offset or zone code?  ZONE_CODE
      Time zone code:               6
      GMT offset:                   N/A
      Temperature logging:          AVERAGE

    TRANSMITTERS:
      Channel   Receive   Retransmit  Repeater    Type
         1      active        Y         NONE      iss
         2      inactive      Y         NONE      (N/A)
         3      inactive      Y         NONE      (N/A)
         4      inactive      Y         NONE      (N/A)
         5      inactive      Y         NONE      (N/A)
         6      inactive      Y         NONE      (N/A)
         7      inactive      Y         NONE      (N/A)
         8      inactive      Y         NONE      (N/A)

    RECEPTION STATS:
      Total packets received:       4618
      Total packets missed:         144
      Number of resynchronizations: 2
      Longest good stretch:         214
      Number of CRC errors:         30

    BAROMETER CALIBRATION DATA:
      Current barometer reading:    29.679 inHg
      Altitude:                     781 feet
      Dew point:                    42 F
      Virtual temperature:          56 F
      Humidity correction factor:   1.8
      Correction ratio:             1.029
      Correction constant:          +0.000 inHg
      Gain:                         0.000
      Offset:                       18.000

    OFFSETS:
      Wind direction:               -45 deg
      Inside Temperature:           +0.0 F
      Inside Humidity:              +0 %
      Outside Temperature:          +0.0 F
      Outside Humidity:             +0 %

jkozik@weewx174:~/weewx51/data$
```
Note the onboard time is very accurate.  I didnt set this.  I think the WifiLogger2 interface sets the time.

## Start the weewx daemon
Start the weewx server for real.  Verify the basics are working.
```
jkozik@weewx174:~/weewx51$ docker compose up -d
[+] Running 2/2
 ✔ Container nginx          Started                                                                                    
 ✔ Container weewx-weewx-1  Started                                                                                    
jkozik@weewx174:~/weewx51$
jkozik@weewx174:~/weewx51$ docker compose ps
NAME            IMAGE              COMMAND                  SERVICE   CREATED          STATUS          PORTS
nginx           nginx              "/docker-entrypoint.…"   nginx     26 minutes ago   Up 26 minutes   0.0.0.0:80->80/tcp, [::]:80->80/tcp
weewx-weewx-1   felddy/weewx:5.1   "./entrypoint.sh"        weewx     26 minutes ago   Up 26 minutes
```
Check the log files to verify that station data is being collected
```
jkozik@weewx174:~/weewx51/data$ docker compose up -d
[+] Running 3/3
 ✔ Network weewx_default    Created                                                                                                                             0.3s
 ✔ Container weewx-weewx-1  Started                                                                                                                             0.9s
 ✔ Container nginx          Started                                                                                                                             0.9s
jkozik@weewx174:~/weewx51/data$ docker compose logs -f
weewx-1  | Using configuration file /data/weewx.conf
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Initializing weewxd version 5.1.0
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Command line: /opt/venv/bin/weewxd --config /data/weewx.conf
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Using Python: 3.13.0 (main, Dec  3 2024, 02:26:48) [GCC 12.2.0]
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Located at:   /opt/venv/bin/python
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Platform:     Linux-6.8.0-57-generic-x86_64-with-glibc2.36
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Locale:       'LC_CTYPE=C.UTF-8;LC_NUMERIC=C;LC_TIME=C;LC_COLLATE=C;LC_MONETARY=C;LC_MESSAGES=C;LC_PAPER=C;LC_NAME=C;LC_ADDRESS=C;LC_TELEPHONE=C;LC_MEASUREMENT=C;LC_IDENTIFICATION=C'
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Entry path:   /opt/venv/bin/weewxd
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: WEEWX_ROOT:   /data
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Config file:  /data/weewx.conf
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: User module:  /data/bin/user
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Debug:        0
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: User:         weewx
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Group:        weewx
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewxd: Groups:       weewx
weewx-1  | 2025-04-14 14:41:02 weewxd[6]: INFO weewx.engine: Loading station type Vantage (weewx.drivers.vantage)
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.engine: StdConvert target unit is 0x1
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.wxservices: StdWXCalculate will use data binding wx_binding
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.manager: Created and initialized table 'archive' in database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.manager: Created daily summary tables
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.engine: Archive will use data binding wx_binding
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.engine: Record generation will be attempted in 'hardware'
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.engine: The archive interval in the configuration file (300) does not match the station hardware interval (600).
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.engine: Using archive interval of 600 seconds (specified by hardware)
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.restx: StationRegistry: Registration not requested.
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.restx: Wunderground: Posting not enabled.
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.restx: PWSweather: Posting not enabled.
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.restx: CWOP: Posting not enabled.
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.restx: WOW: Posting not enabled.
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.restx: AWEKAS: Posting not enabled.
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewx.engine: 'pyephem' detected, extended almanac data is available
weewx-1  | 2025-04-14 14:41:07 weewxd[6]: INFO weewxd: Starting up weewx version 5.1.0
nginx    | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
nginx    | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
nginx    | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
nginx    | 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
nginx    | 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
nginx    | /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
nginx    | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
nginx    | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
nginx    | /docker-entrypoint.sh: Configuration complete; ready for start up
nginx    | 2025/04/14 19:41:02 [notice] 1#1: using the "epoll" event method
nginx    | 2025/04/14 19:41:02 [notice] 1#1: nginx/1.27.4
nginx    | 2025/04/14 19:41:02 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
nginx    | 2025/04/14 19:41:02 [notice] 1#1: OS: Linux 6.8.0-57-generic
nginx    | 2025/04/14 19:41:02 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
nginx    | 2025/04/14 19:41:02 [notice] 1#1: start worker processes
nginx    | 2025/04/14 19:41:02 [notice] 1#1: start worker process 28
weewx-1  | 2025-04-14 14:41:09 weewxd[6]: INFO weewx.engine: Clock error is -0.52 seconds (positive is fast)
weewx-1  | 2025-04-14 14:41:09 weewxd[6]: INFO weewx.engine: Using binding 'wx_binding' to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:09 weewxd[6]: INFO weewx.manager: Starting backfill of daily summaries
weewx-1  | 2025-04-14 14:41:09 weewxd[6]: INFO weewx.manager: Empty database
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 09:10:00 CDT (1743689400) to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 09:10:00 CDT (1743689400) to daily summary in 'weewx.sdb'
weewx-1  | REC:    2025-04-03 09:10:00 CDT (1743689400) 'altimeter': 'None', 'appTemp': '43.91764913173297', 'barometer': '29.994', 'cloudbase': '3062.0026879723287', 'dateTime': '1743689400', 'dewpoint': '37.663588172921756', 'ET': '0.0', 'heatindex': '45.366', 'highOutTemp': '47.9', 'highRadiation': '264.0', 'highUV': '1.3', 'humidex': '47.7', 'inDewpoint': '46.85541453653479', 'inHumidity': '38.0', 'inTemp': '74.1', 'interval': '10', 'lowOutTemp': '47.5', 'maxSolarRad': '412.64327154938843', 'outHumidity': '68.0', 'outTemp': '47.7', 'pressure': 'None', 'radiation': '241.0', 'rain': '0.0', 'rainRate': '0.0', 'rxCheckPercent': '95.66666666666666', 'usUnits': '1', 'UV': '1.3', 'wind_samples': '224.0', 'windchill': '47.7', 'windDir': '135.0', 'windGust': '7.0', 'windGustDir': '67.5', 'windrun': '0.3333333333333333', 'windSpeed': '2.0'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 11:30:00 CDT (1743697800) to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 11:30:00 CDT (1743697800) to daily summary in 'weewx.sdb'
weewx-1  | REC:    2025-04-03 11:30:00 CDT (1743697800) 'altimeter': 'None', 'appTemp': '43.28159465884046', 'barometer': '29.997', 'cloudbase': '2971.6654927212844', 'dateTime': '1743697800', 'dewpoint': '37.46107183202635', 'ET': '0.0', 'heatindex': '44.753', 'highOutTemp': '47.5', 'highRadiation': '221.0', 'highUV': '1.2', 'humidex': '47.1', 'inDewpoint': '47.36744676304085', 'inHumidity': '39.0', 'inTemp': '73.9', 'interval': '10', 'lowOutTemp': '46.7', 'maxSolarRad': '775.9227414349572', 'outHumidity': '69.0', 'outTemp': '47.1', 'pressure': 'None', 'radiation': '196.0', 'rain': '0.0', 'rainRate': '0.0', 'rxCheckPercent': '100.0', 'usUnits': '1', 'UV': '1.1', 'wind_samples': '344.0', 'windchill': '47.1', 'windDir': '135.0', 'windGust': '7.0', 'windGustDir': '67.5', 'windrun': '0.3333333333333333', 'windSpeed': '2.0'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 11:40:00 CDT (1743698400) to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 11:40:00 CDT (1743698400) to daily summary in 'weewx.sdb'
weewx-1  | REC:    2025-04-03 11:40:00 CDT (1743698400) 'altimeter': 'None', 'appTemp': '42.18650841111375', 'barometer': '29.997', 'cloudbase': '3051.845143159496', 'dateTime': '1743698400', 'dewpoint': '36.70828137009822', 'ET': '0.0', 'heatindex': '44.266000000000005', 'highOutTemp': '46.8', 'highRadiation': '227.0', 'highUV': '1.2', 'humidex': '46.7', 'inDewpoint': '47.278422897872616', 'inHumidity': '39.0', 'inTemp': '73.8', 'interval': '10', 'lowOutTemp': '46.5', 'maxSolarRad': '790.6752660794824', 'outHumidity': '68.0', 'outTemp': '46.7', 'pressure': 'None', 'radiation': '215.0', 'rain': '0.0', 'rainRate': '0.0', 'rxCheckPercent': '99.08333333333333', 'usUnits': '1', 'UV': '1.2', 'wind_samples': '232.0', 'windchill': '46.7', 'windDir': '202.5', 'windGust': '12.0', 'windGustDir': '202.5', 'windrun': '0.5', 'windSpeed': '3.0'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 11:50:00 CDT (1743699000) to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 11:50:00 CDT (1743699000) to daily summary in 'weewx.sdb'
weewx-1  | REC:    2025-04-03 11:50:00 CDT (1743699000) 'altimeter': 'None', 'appTemp': '41.72090366208311', 'barometer': '30.0', 'cloudbase': '3047.788327965577', 'dateTime': '1743699000', 'dewpoint': '36.32613135695146', 'ET': '0.0', 'heatindex': '43.82599999999999', 'highOutTemp': '46.5', 'highRadiation': '200.0', 'highUV': '1.1', 'humidex': '46.3', 'inDewpoint': '46.92230602853764', 'inHumidity': '39.0', 'inTemp': '73.4', 'interval': '10', 'lowOutTemp': '46.0', 'maxSolarRad': '803.675098344284', 'outHumidity': '68.0', 'outTemp': '46.3', 'pressure': 'None', 'radiation': '191.0', 'rain': '0.0', 'rainRate': '0.0', 'rxCheckPercent': '99.08333333333333', 'usUnits': '1', 'UV': '1.1', 'wind_samples': '232.0', 'windchill': '46.3', 'windDir': '180.0', 'windGust': '9.0', 'windGustDir': '202.5', 'windrun': '0.5', 'windSpeed': '3.0'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 12:00:00 CDT (1743699600) to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 12:00:00 CDT (1743699600) to daily summary in 'weewx.sdb'
weewx-1  | REC:    2025-04-03 12:00:00 CDT (1743699600) 'altimeter': 'None', 'appTemp': '41.819435242949076', 'barometer': '30.014', 'cloudbase': '3043.7350575149776', 'dateTime': '1743699600', 'dewpoint': '35.9439657469341', 'ET': '0.004', 'forecastRule': '1', 'heatindex': '43.386', 'highOutTemp': '46.0', 'highRadiation': '227.0', 'highUV': '1.3', 'humidex': '45.9', 'inDewpoint': '45.96788856051751', 'inHumidity': '38.0', 'inTemp': '73.1', 'interval': '10', 'lowOutTemp': '45.8', 'maxSolarRad': '814.8930844350141', 'outHumidity': '68.0', 'outTemp': '45.9', 'pressure': 'None', 'radiation': '202.0', 'rain': '0.0', 'rainRate': '0.0', 'rxCheckPercent': '99.08333333333333', 'usUnits': '1', 'UV': '1.1', 'wind_samples': '232.0', 'windchill': '45.9', 'windDir': '135.0', 'windGust': '8.0', 'windGustDir': '202.5', 'windrun': '0.3333333333333333', 'windSpeed': '2.0'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 12:10:00 CDT (1743700200) to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 12:10:00 CDT (1743700200) to daily summary in 'weewx.sdb'
weewx-1  | REC:    2025-04-03 12:10:00 CDT (1743700200) 'altimeter': 'None', 'appTemp': '41.703385255504145', 'barometer': '30.024', 'cloudbase': '3042.7222937939014', 'dateTime': '1743700200', 'dewpoint': '35.84842190730683', 'ET': '0.0', 'forecastRule': '1', 'heatindex': '43.275999999999996', 'highOutTemp': '46.0', 'highRadiation': '230.0', 'highUV': '1.3', 'humidex': '45.8', 'inDewpoint': '45.79035708593977', 'inHumidity': '38.0', 'inTemp': '72.9', 'interval': '10', 'lowOutTemp': '45.8', 'maxSolarRad': '824.3038172416536', 'outHumidity': '68.0', 'outTemp': '45.8', 'pressure': 'None', 'radiation': '221.0', 'rain': '0.0', 'rainRate': '0.0', 'rxCheckPercent': '99.08333333333333', 'usUnits': '1', 'UV': '1.2', 'wind_samples': '232.0', 'windchill': '45.8', 'windDir': '135.0', 'windGust': '7.0', 'windGustDir': '67.5', 'windrun': '0.3333333333333333', 'windSpeed': '2.0'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 12:20:00 CDT (1743700800) to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 12:20:00 CDT (1743700800) to daily summary in 'weewx.sdb'
weewx-1  | REC:    2025-04-03 12:20:00 CDT (1743700800) 'altimeter': 'None', 'appTemp': '41.872861223868284', 'barometer': '30.034', 'cloudbase': '3129.6752758548214', 'dateTime': '1743700800', 'dewpoint': '35.665828786238784', 'ET': '0.0', 'forecastRule': '1', 'heatindex': '43.449', 'highOutTemp': '46.1', 'highRadiation': '241.0', 'highUV': '1.3', 'humidex': '46.0', 'inDewpoint': '45.52404344642456', 'inHumidity': '38.0', 'inTemp': '72.6', 'interval': '10', 'lowOutTemp': '45.9', 'maxSolarRad': '831.8864876815368', 'outHumidity': '67.0', 'outTemp': '46.0', 'pressure': 'None', 'radiation': '232.0', 'rain': '0.0', 'rainRate': '0.0', 'rxCheckPercent': '99.9375', 'usUnits': '1', 'UV': '1.3', 'wind_samples': '234.0', 'windchill': '46.0', 'windDir': '180.0', 'windGust': '7.0', 'windGustDir': '135.0', 'windrun': '0.3333333333333333', 'windSpeed': '2.0'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 12:30:00 CDT (1743701400) to database 'weewx.sdb'
weewx-1  | 2025-04-14 14:41:13 weewxd[6]: INFO weewx.manager: Added record 2025-04-03 12:30:00 CDT (1743701400) to daily summary in 'weewx.sdb'
```
Note: the weewx daemon is running in a docker container.  There are actualy two of them.  There's another container that is running an nginx web server.  Weewx will periodically generate a web page.  Nginx will render it on port 80.

Take a look at the log files.  When the reportengine generates some content, verify that the public_html directory has been filled. (It took me about 15 minutes).

```
jkozik@weewx174:~/weewx51/data/public_html$ docker compose logs -f
.-=-=-=-=-=...
weewx-1  | LOOP:   2025-04-13 21:40:20 CDT (1744598420) 'altimeter': '29.688021688751935', 'appTemp': '57.47425693546715', 'barometer': '29.678', 'cloudbase': '5029.702621037409', 'consBatteryVoltage': '5.06', 'dateTime': '1744598420', 'dayET': '0.073', 'dayRain': '0.0', 'dewpoint': '41.3057084674354', 'ET': 'None', 'extraAlarm1': '0', 'extraAlarm2': '0', 'extraAlarm3': '0', 'extraAlarm4': '0', 'extraAlarm5': '0', 'extraAlarm6': '0', 'extraAlarm7': '0', 'extraAlarm8': '0', 'forecastIcon': '3', 'forecastRule': '192', 'heatindex': '58.050000000000004', 'humidex': '60.0', 'inDewpoint': '42.961264259077744', 'inHumidity': '34.0', 'insideAlarm': '0', 'inTemp': '73.0', 'maxSolarRad': '0.0', 'monthET': '0.76', 'monthRain': '0.0', 'outHumidity': '50.0', 'outsideAlarm1': '0', 'outsideAlarm2': '0', 'outTemp': '60.0', 'pressure': '28.855837234414036', 'radiation': '0.0', 'rain': '0.0', 'rainAlarm': '0', 'rainRate': '0.0', 'soilLeafAlarm1': '0', 'soilLeafAlarm2': '0', 'soilLeafAlarm3': '0', 'soilLeafAlarm4': '0', 'stormRain': '0.0', 'sunrise': '1744542780', 'sunset': '1744590660', 'txBatteryStatus': '0', 'usUnits': '1', 'UV': '0.0', 'windchill': '60.0', 'windDir': '43.0', 'windGust': '2.0', 'windGustDir': '38.0', 'windrun': 'None', 'windSpeed': '1.0', 'windSpeed10': '0.0', 'yearET': '4.0', 'yearRain': '2.91'
weewx-1  | 2025-04-13 21:40:20 weewxd[6]: INFO weewx.imagegenerator: Generated 60 images for report SeasonsReport in 1.70 seconds
weewx-1  | 2025-04-13 21:40:20 weewxd[6]: INFO weewx.reportengine: Copied 5 files to /data/public_html
^C
jkozik@weewx174:~/weewx51/data/public_html$ ls
celestial.html    daytempdew.png   favicon.ico         monthrain.png      monthwind.png     telemetry.html     weektempdew.png   yearbarometer.png  yeartempfeel.png
daybarometer.png  daytempfeel.png  font                monthrx.png        monthwindvec.png  weekbarometer.png  weektempfeel.png  yearET.png         yeartempin.png
dayET.png         daytempin.png    index.html          monthtempdew.png   NOAA              weekET.png         weektempin.png    yearhumin.png      yearUV.png
dayhumin.png      dayUV.png        monthbarometer.png  monthtempfeel.png  rss.xml           weekhumin.png      weekUV.png        yearhum.png        yearvolt.png
dayhum.png        dayvolt.png      monthET.png         monthtempin.png    seasons.css       weekhum.png        weekvolt.png      yearradiation.png  yearwinddir.png
dayradiation.png  daywinddir.png   monthhumin.png      monthUV.png        seasons.js        weekradiation.png  weekwinddir.png   yearrain.png       yearwind.png
dayrain.png       daywind.png      monthhum.png        monthvolt.png      statistics.html   weekrain.png       weekwind.png      yearrx.png         yearwindvec.png
dayrx.png         daywindvec.png   monthradiation.png  monthwinddir.png   tabular.html      weekrx.png         weekwindvec.png   yeartempdew.png
jkozik@weewx174:~/weewx51/data/public_html$
jkozik@weewx174:~/weewx51/data/public_html$ curl http://192.168.100.174 | head
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 24857  100
2
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>weewx.kozik.net</title>
    <link rel="icon" type="image/png" href="favicon.ico" />
    <link rel="stylesheet" type="text/css" href="seasons.css"/>
4857    0     0  16.8M      0 --:--:-- --:--:-- --:--:-- 23.7M
curl: Failed writing body
jkozik@weewx174:~/weewx51/data/public_html$ curl http://192.168.100.174 | head -20
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0

1
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>weewx.kozik.net</title>
    <link rel="icon" type="image/png" href="favicon.ico" />
    <link rel="stylesheet" type="text/css" href="seasons.css"/>
    <script src="seasons.js"></script>


  </head>

  <body onload="setup();">


<div id="title_bar">
  <div id="title">
00 24857  100 24857    0     0  14.7M      0 --:--:-- --:--:-- --:--:-- 23.7M
curl: Failed writing body
jkozik@weewx174:~/weewx51/data/public_html$ curl http://192.168.100.174 | head -30
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0


<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>weewx.kozik.net</title>
    <link rel="icon" type="image/png" href="favicon.ico" />
    <link rel="stylesheet" type="text/css" href="seasons.css"/>
    <script src="seasons.js"></script>


  </head>

  <body onload="setup();">


<div id="title_bar">
  <div id="title">
    <h1 class="page_title">weewx.kozik.net</h1>
    <p class="lastupdate">04/13/25 21:40:00</p>
  </div>
  <div id="rss_link"><a href="rss.xml">RSS</a></div>
  <div id="reports">
    Monthly Reports:
    <select name="reports" onchange="openTabularFile(value)">
      <option value="2025-04">2025-04</option>
      <option selected>- Select Month -</option>
    </select>
```
## Verify the webpage http://192.168.100.174
![image](https://github.com/user-attachments/assets/589bfadc-220f-44b5-bcff-bcfba4a7a2ab)

# References
- [Weewx5.1 Install using Pip](https://weewx.com/docs/5.1/quickstarts/pip/)
- [weewx-docker](https://github.com/felddy/weewx-docker) repository by [felddy](https://github.com/felddy)
