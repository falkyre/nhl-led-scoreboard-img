<p align="center">
<a href="https://github.com/riffnshred/nhl-led-scoreboard">
<img src="https://github.com/riffnshred/nhl-led-scoreboard/blob/master/assets/images/scoreboard.jpg" height="150">
</a>
</p>

<span align="center">

# NHL LED Scoreboard Raspberry Pi Image
[![.github/workflows/main.yml](https://github.com/falkyre/nhl-led-scoreboard-img/actions/workflows/main.yml/badge.svg)](https://github.com/falkyre/nhl-led-scoreboard-img/actions/workflows/main.yml)
[![GitHub release (latest by date)](https://badgen.net/github/release/falkyre/nhl-led-scoreboard-img?label=Version)](https://github.com/falkyre/nhl-led-scoreboard-img/releases/latest)


</span>

This project provides a free [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) based Raspberry Pi image with [NHL LED Scoreboard](https://github.com/riffnshred/nhl-led-scoreboard) pre-installed.

* Works on all Raspberry Pi models
* Built on Raspbian Lite (no desktop)
* Simple WiFi Setup 

This image also provides a command called `sb-tools` which helps you with various tools to run and configure the scoreboard in a text/terminal based GUI.  There are also a set of command line aliases that provide similar functionaity without a GUI.  See [Command Line Utilities](#NHL-Led-Scoreboard-command-line-utilities) for a list

## Download

Downloading the *NHL LED Scoreboard Raspberry Pi Image* is completely free (no sign up required).

<span align="center">
  
### [Download Latest Version](https://github.com/falkyre/nhl-led-scoreboard-img/releases/latest)
  
</span>

## Flash to SD Card

The easiest way to flash the *NHL LED Scoreboard Raspberry Pi Image* to your SD card is to use [Etcher](https://www.balena.io/etcher/).
  
<p align="center">
    <img src="https://user-images.githubusercontent.com/3979615/74733445-789cac00-52a0-11ea-9167-05b42d6383ad.gif" width="600">
</p>

1. Download and install the latest version of [Etcher](https://www.balena.io/etcher/).
2. Open Etcher and select the `rpios-scoreboard-v0.0.0.zip` file you have [downloaded](https://github.com/falkyre/nhl-led-scoreboard-img/releases/latest). There is no need to extract the `.zip` file first.
3. Choose the drive your SD card has been inserted into.
4. Click Flash.

## First Boot / Network Setup

Now that you have flashed your SD card, you can insert it into your Raspberry Pi.  Your Raspberry Pi will expand the size of your SD card to utilize it fully.  This can take some time depending on the size and health of your card.


## Default Settings

|                               |                 |
|-------------------------------|------------------------------------------|
| **Default Hostname**          | `scoreboard-####.local`                       |
| **Default SSH Username**      | `pi`                                     |
| **Default SSH Password**      | `scoreboard`                              |
| **Hot Spot Wifi SSID**        | `NHL LED Scoreboard ####`                 |
| **Hot Spot Wifi Password**    | `12345678` |

`####` will be set to the last 4 characters of the serial number of your raspberry pi.


### WiFi Setup

Follow these steps to connect your device to WiFi:

1. Power on your device without an Ethernet cable attached.
2. Wait 1-2 minutes (if first boot, the SD card will need to be expanded so this may take longer)
3. Use your mobile phone to scan for new WiFi networks
4. Connect to the hotspot named **NHL Led Scoreboard ####** where `####` is the last 4 digits of the serial number of your raspberry pi (take note of these 4 digits as your new hostname will contain them) or `http://10.0.0.1`  The wifi password is `12345678` for the hot spot.
6. Wait a few moments until the captive portal opens, this portal will allow you to connect the Raspberry Pi to your local WiFi network.  If the captive portal does not open, connect to your raspberry pi at `http://10.0.0.1`

If you enter your WiFi credentials incorrectly the **NHL Led Scoreboard ####** hotspot will reappear allowing you to try again.

## First Boot / Network Setup

After you set your WiFi connection, the raspberry pi will reboot and connect to your router.  To find your raspberry pi, the following can be attempted: 

1. Login to your router and find the "connected devices" or "dhcp clients" page to find the IP address that was assigned to the Raspberry Pi.
2. Download the [Fing](https://www.fing.com/) app for [iOS](https://itunes.apple.com/us/app/fing-network-scanner/id430921107?mt=8) or [Android](https://play.google.com/store/apps/details?id=com.overlook.android.fing&hl=en_GB) to scan your network to find the IP address of your Raspberry Pi.
3. Try to `ping scoreboard-####.local` where `####` comes from point 4 in the wifi hot spot above.  The ping will show the IP address of your pi.

See the wiki [How to Find IP Address](https://github.com/falkyre/nhl-led-scoreboard-img/wiki/How-To-Find-IP-Address)

## SSH Access

SSH is enabled by default. The default username is `pi` with password `scoreboard`.
See the wiki [Connect with SSH](https://github.com/falkyre/nhl-led-scoreboard-img/wiki/Connect-with-SSH) for more information and links.


## Community

The official NHL LED Scoreboard Discord server where users can discuss NHL LED Scoreboard and ask for help.

<span align="center">

[![NHL LED Scoreboard Discord](https://discordapp.com/api/guilds/648168455450656798/widget.png?style=banner2)](https://discord.gg/CWa5CzK) 

</span>

[NHL LED Scoreboard Forum](https://github.com/riffnshred/nhl-led-scoreboard/discussions)
## NHL Led Scoreboard command line utilities

This table contains important information about the command line tools you can use. 

|    General Tools                           | Command                  |
|-------------------------------|------------------------------------------|
| **Help Command**           | `sb-help`                |
| **Manage NHL LED Scoreboard**  | `sb-tools`                         |
| **system info Command**           | `sb-sysinfo`                |
| **Reset Wifi to Hot Spot**           | `sb-resetwifi`                |



|    Troubleshooting Tools                           | Command                  |
|-------------------------------|------------------------------------------|
| **View Live Logs Command**         | `sb-livelog`                    |
| **View output, last 50kb**         | `sb-stdout`                    |
| **View errors, last 50kb**         | `sb-stderr`                    |
| **Collect files for github issue**         | `sb-issue`                    |

|    Update Tools                           | Command                  |
|-------------------------------|------------------------------------------|
| **Check for Update**         | `sb-updatecheck`                    |
| **Show changelog for latest version**         | `sb-changelog`                    |
| **Upgrade to latest version**         | `sb-upgrade`                    |

|    Supervisor/Process Tools                           | Command                  |
|-------------------------------|------------------------------------------|
| **Status Command**           | `sb-status`                |
| **Restart Command**           | `sb-restart`                |
| **Stop Command**              | `sb-stop`                   |
| **Start Command**             | `sb-start`                  |



## Raspberty Pi OS Settings

This raspberry pi image is built on top of the latest Raspberry Pi OS lite.  Added to this version is the following:

* Auto set timezone based on geolocation of your IP address. 
* There is a login banner that shows various system info for your raspberry pi (including timezone).  It can manually be run by using the `sb-sysinfo`
* /var/log, swap and /home/pi are all set to exist in zram.  /var/log and /homepi will get written back to the SD card on boot or under a filesystem sync.  Settings for the sizes are in /etc/ztab
* The size for zram of the /home/pi directory is currently set to 350M compressed.  There is room for another repository to be installed if you wish.  If you don't want the /home/pi to be run from zram, then edit the /etc/ztab as root user and comment out the line with /home/pi.
* raspi-config is still available with all options as a normal raspberry pi.  So if your time zone is not set correctly or you don't like your hostname, you can still use raspi-config for changes
* Locale is set to en_US.UTF_8 which is needed for the weather icons to work correctly.
* Inital timezone is America/Toronto
