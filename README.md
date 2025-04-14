# weewx51
Setup weewx51 in docker compose environment
## clone repository
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
## run for the first time
```
jkozik@weewx174:~/weewx51$ mkdir -p  data;docker compose run --rm weewx
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







# References
- [Weewx5.1 Install using Pip](https://weewx.com/docs/5.1/quickstarts/pip/)
- [weewx-docker](https://github.com/felddy/weewx-docker) repository by [felddy](https://github.com/felddy)
