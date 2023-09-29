<p align="center">
<a href="https://github.com/riffnshred/nhl-led-scoreboard">
<img src="https://github.com/riffnshred/nhl-led-scoreboard/blob/master/assets/images/scoreboard.jpg" height="150">
</a>
</p>

<span align="center">

# NHL LED Scoreboard Raspberry Pi Image
[![Create Release - Image](https://github.com/falkyre/nhl-led-scoreboard-img/actions/workflows/main.yml/badge.svg)](https://github.com/falkyre/nhl-led-scoreboard-img/actions/workflows/main.yml)
[![GitHub release (latest by date)](https://badgen.net/github/release/falkyre/nhl-led-scoreboard-img?label=Version&cache=600)](https://github.com/falkyre/nhl-led-scoreboard-img/releases/latest)
![GitHub all releases](https://badgen.net/github/assets-dl/falkyre/nhl-led-scoreboard-img?cache=600)



</span>

This project provides a free [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) based Raspberry Pi image with [NHL LED Scoreboard](https://github.com/riffnshred/nhl-led-scoreboard) pre-installed.  This is built with the Hasicorp packer with the packer-builder-arm plugin (https://github.com/mkaczanowski/packer-builder-arm) in a docker image extended with ansible.  Ansible is used to do the provisioning of the image.  For more information, see the [BUILD](https://github.com/falkyre/nhl-led-scoreboard-img/tree/packer/nhl-image/BUILD.md) documentation.

* Works on all Raspberry Pi models
* Built on Raspbian Lite (no desktop)
* Simple WiFi Setup (Ethernet setup not tested and should only be done by advanced users) using the [comitup](http://davesteele.github.io/comitup/) utility.

This image also provides a command called `sb-tools` which helps you with various tools to run and configure the scoreboard in a text/terminal based GUI.  There are also a set of command line aliases that provide similar functionaity without a GUI.  See [Command Line Utilities](#NHL-Led-Scoreboard-command-line-utilities) for a list.

### Note about python
Everything python related is now installed in a virtual environment that is located in the /home/pi/nhl-led-scoreboard/venv directory.  The bashrc script contains code that will auto activate the venv and deactivate upson entering and leaving the /home/pi/nhl-led-scoreboard directory.  The purpose behind this is to keep the OS install as clean as possible (and will be the way the upcoming RaspiOS Bookworm will require python installs to be).  In order to run the code from the command line using sudo, the python command **`must`** now reference the virtual environment installation and not the globally installed one.  Everything is handled with the image but if you are asked to run the code via command line for troubleshooting issues, see below.

Here's a comparison of how to run the scoreboard (assuming you are in the nhl-led-scoreboard directory)

**Previous way with everything globally install as root user**

> `sudo python3 ./src/main.py [command line options]`

**Now with the venv**
> `sudo /home/pi/nhl-led-scoreboard/venv/bin/python3 ./src/main.py [command line options]`


## Download

Downloading the *NHL LED Scoreboard Raspberry Pi Image* is completely free (no sign up required).

<span align="center">
  
### [Download Latest Version](https://github.com/falkyre/nhl-led-scoreboard-img/releases/latest)
  
</span>

If you'd like to support me:

<a href="https://www.buymeacoffee.com/falkyre" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/arial-red.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>


## Flash to SD Card

The easiest way to flash the *NHL LED Scoreboard Raspberry Pi Image* to your SD card is to use [Etcher](https://www.balena.io/etcher/).
  
<p align="center">
    <img src="https://user-images.githubusercontent.com/3979615/74733445-789cac00-52a0-11ea-9167-05b42d6383ad.gif" width="600">
</p>

1. Download and install the latest version of [Etcher](https://www.balena.io/etcher/).
2. Open Etcher and select the `rpios-scoreboard-v0.0.0.zip` file you have [downloaded](https://github.com/falkyre/nhl-led-scoreboard-img/releases/latest). There is no need to extract the `.zip` file first.
3. Choose the drive your SD card has been inserted into.
4. Click Flash.

## First Boot 

Now that you have flashed your SD card, you can insert it into your Raspberry Pi.  Your Raspberry Pi will expand the size of your SD card to utilize it fully.  This can take some time depending on the size and health of your card.  Once the Raspberry Pi has expanded the filesystem, it will launch a Captive Portal that you can log into to set your WiFi.  On an iPhone, this should open safari automatically.  On Android 10 and 11, it shows up as manage your router in the WiFi details in the settings.  Android now will open captive portal webpage automatically as well.  If you don't see it, use the manage router in WiFi details.




## Default Settings

|                               |                 |
|-------------------------------|------------------------------------------|
| **Default Hostname**          | `scoreboard.local`                       |
| **Default SSH Username**      | `pi`                                     |
| **Default SSH Password**      | `scoreboard`                              |
| **Hot Spot Wifi SSID**        | `scoreboard-####`                 |


`####` will be set to the a random set of 4 digits.


### WiFi Setup

Follow these steps to connect your device to WiFi:

1. Power on your device without an Ethernet cable attached.
2. Wait 1-2 minutes (if first boot, the SD card will need to be expanded so this may take longer)
3. Use your mobile phone to scan for new WiFi networks
4. Connect to the hotspot named **scoreboard-####** where `####` is the a random set of 4 digits.  There is no wifi password required.
6. Wait a few moments until the captive portal opens, this portal will allow you to connect the Raspberry Pi to your local WiFi network.  If the captive portal does not open, connect to your raspberry pi at `http://10.41.0.1`

If you enter your WiFi credentials incorrectly the **NHL Led Scoreboard** hotspot will reappear allowing you to try again.

## First Boot / Network Setup

After you set your WiFi connection, the raspberry pi will reboot and connect to your router.  To find your raspberry pi, the following can be attempted: 

1. Login to your router and find the "connected devices" or "dhcp clients" page to find the IP address that was assigned to the Raspberry Pi.
2. Download the [Fing](https://www.fing.com/) app for [iOS](https://itunes.apple.com/us/app/fing-network-scanner/id430921107?mt=8) or [Android](https://play.google.com/store/apps/details?id=com.overlook.android.fing&hl=en_GB) to scan your network to find the IP address of your Raspberry Pi.
3. Try to `ping scoreboard.local`.  The ping will show the IP address of your pi.

See the wiki [How to Find IP Address](https://github.com/falkyre/nhl-led-scoreboard-img/wiki/How-To-Find-IP-Address)

## SSH Access

SSH is enabled by default. The default username is `pi` with password `scoreboard`.
See the wiki [Connect with SSH](https://github.com/falkyre/nhl-led-scoreboard-img/wiki/Connect-with-SSH) for more information and links.

## First login
You will need to SSH to your Raspberry Pi to finalize some settings for getting the NHL LED Scoreboard to work.  On first login, you will be prompted to select a single team (to create a basic config.json), the size of your board and if you have the antiflicker mod for the adafruit boards, then it will run a test script that will display the latest version of the NHL LED Scoreboard software.  If that passes, you will be asked to enable the supervisor and then the raspberry pi will reboot.

On reboot, if everything is working you will see a splash screen, then a loading image and the NHL LED Scoreboard will run wth the basic config.json created on the first initial log in.  If you want to change the config.json, either edit the file by hand or use the /home/pi/nhl-led-scoreboard/nhl_setup tool.

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

* Auto set timezone based on geolocation of your IP address. Initial time zone is America/Toronto because we all know that's the center of the universe.
* There is a login banner that shows various system info for your raspberry pi (including timezone).  It can manually be run by using the `sb-sysinfo`
* /var/log, swap and /home/pi are all set to exist in zram.  /var/log and /homepi will get written back to the SD card on boot or under a filesystem sync.  Settings for the sizes are in /etc/ztab
* The size for zram of the /home/pi directory is currently set to 350M compressed.  There is room for another repository to be installed if you wish.  If you don't want the /home/pi to be run from zram, then edit the /etc/ztab as root user and comment out the line with /home/pi.
* raspi-config is still available with all options as a normal raspberry pi.  So if your time zone is not set correctly or you don't like your hostname, you can still use raspi-config for changes
* Locale is set to en_US.UTF_8 which is needed for the weather icons to work correctly.

