<p align="center">
<a href="https://github.com/riffnshred/nhl-led-scoreboard">
<img src="https://github.com/riffnshred/nhl-led-scoreboard/blob/master/assets/images/scoreboard.jpg" height="150">
</a>
</p>

<span align="center">

# NHL LED Scoreboard Raspberry Pi Image
[![.github/workflows/main.yml](https://github.com/falkyre/nhl-led-portal-img/actions/workflows/main.yml/badge.svg)](https://github.com/falkyre/nhl-led-portal-img/actions/workflows/main.yml)
[![GitHub release (latest by date)](https://badgen.net/github/release/falkyre/nhl-led-portal-img?label=Version)](https://github.com/falkyre/nhl-led-portal-img/releases/latest)
[![GitHub All Releases](https://img.shields.io/github/downloads/falkyre/nhl-led-portal-img/total)](https://somsubhra.com/github-release-stats/?username=homebridge&repository=homebridge-raspbian-image)

</span>

This project provides a free [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) based Raspberry Pi image with [NHL LED Scoreboard](https://github.com/riffnshred/nhl-led-scoreboard) pre-installed.

* Works on all Raspberry Pi models
* Built on Raspbian Lite (no desktop)
* Simple WiFi Setup

This image also provides a command called `sb-tools` which helps you with various tools to run and configure the scoreboard in a text/terminal based GUI.  There are also a set of command line aliases that provide similar functionaity without a GUI.  

## Download

Downloading the *NHL LED Scoreboard Raspberry Pi Image* is completely free (no sign up required).

<span align="center">
  
### [Download Latest Version](https://github.com/falkyre/nhl-led-portal-img/releases/latest)
  
</span>

## Flash to SD Card

The easiest way to flash the *NHL LED Scoreboard Raspberry Pi Image* to your SD card is to use [Etcher](https://www.balena.io/etcher/).
  
<p align="center">
    <img src="https://user-images.githubusercontent.com/3979615/74733445-789cac00-52a0-11ea-9167-05b42d6383ad.gif" width="600">
</p>

1. Download and install the latest version of [Etcher](https://www.balena.io/etcher/).
2. Open Etcher and select the `Homebridge-Raspbian-v0.0.0.zip` file you have [downloaded](https://github.com/homebridge/homebridge-raspbian-image/releases/latest). There is no need to extract the `.zip` file first.
3. Choose the drive your SD card has been inserted into.
4. Click Flash.

## First Boot / Network Setup

Now that you have flashed your SD card, you can insert it into your Raspberry Pi.

### WiFi Setup

Follow these steps to connect your device to WiFi:

1. Power on your device without an Ethernet cable attached.
2. Wait 1-2 minutes
3. Use your mobile phone to scan for new WiFi networks
4. Connect to the hotspot named **NHL Led Scoreboard #### Setup** where `####` is the last 4 digits of the serial number of your raspberry pi or `http://10.0.0.1`
6. Wait a few moments until the captive portal opens, this portal will allow you to connect the Raspberry Pi to your local WiFi network.

If you enter your WiFi credentials incorrectly the **NHL Led Scoreboard #### Setup** hotspot will reappear allowing you to try again.

1. Login to your router and find the "connected devices" or "dhcp clients" page to find the IP address that was assigned to the Raspberry Pi.
2. Use an iPhone to access `http://homebridge.local`, once you login using the default username and password (admin/admin) you can find the IP address under System Information.
3. Download the [Fing](https://www.fing.com/) app for [iOS](https://itunes.apple.com/us/app/fing-network-scanner/id430921107?mt=8) or [Android](https://play.google.com/store/apps/details?id=com.overlook.android.fing&hl=en_GB) to scan your network to find the IP address of your Raspberry Pi.
4. As a last resort, if you plug a monitor into your Raspberry Pi, the IP address will be displayed on the attached screen once it has finished booting.


You should take a moment to review the [Configuration Reference](#configuration-reference) at the bottom of this guide.

## SSH Access

SSH is enabled by default. The default username is `pi` with password `scoreboard`.

* [How To Connect Via SSH](https://github.com/homebridge/homebridge-raspbian-image/wiki/How-To-Connect-Via-SSH)

## Community

The official Homebridge Discord server and Reddit community are where users can discuss Homebridge and ask for help.

<span align="center">

[![Homebridge Discord](https://discordapp.com/api/guilds/432663330281226270/widget.png?style=banner2)](https://discord.gg/kqNCe2D) [![Homebridge Reddit](.github/homebridge-reddit.svg?sanitize=true)](https://www.reddit.com/r/homebridge/)

</span>

## Configuration Reference

This table contains important information about your setup. You can use the information provided here as a reference when configuring or troubleshooting your environment.

|                               | File Location / Command                  |
|-------------------------------|------------------------------------------|
| **Config File Path**          | `/var/lib/homebridge/config.json`        |
| **Storage Path**              | `/var/lib/homebridge`                    |
| **Restart Command**           | `sudo hb-service restart`                |
| **Stop Command**              | `sudo hb-service stop`                   |
| **Start Command**             | `sudo hb-service start`                  |
| **View Logs Command**         | `sudo hb-service logs`                   |
| **Manage Homebridge Server**  | `sudo hb-config`                         |
| **Systemd Service File**      | `/etc/systemd/system/homebridge.service` |
| **Systemd Env File**          | `/etc/default/homebridge`                |
| **Default Hostname**          | `homebridge.local`                       |
| **Default SSH Username**      | `pi`                                     |
| **Default SSH Password**      | `raspberry`                              |
| **Default Web Username**      | `admin`                                  |
| **Default Web Password**      | `admin`                                  |

The *Homebridge Raspberry Pi Image* wiki contains more information and instructions on how to further customise your install:

https://github.com/homebridge/homebridge-raspbian-image/wiki
