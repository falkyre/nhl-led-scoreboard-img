## v2.0.0-beta4

### Features

 - [`8dd3371`](https://github.com/falkyre/nhl-led-portal-img/commits/8dd3371) [stage2/04-scoreboard] Add firstrun in .bashrc to force user to setup the scoreboard config and test their matrix.  This will also enable the supervisor and the statup splash animation
 - [`58c3d0d`](https://github.com/falkyre/nhl-led-portal-img/commits/58c3d0d) [stage2/04-scoreboard] Add sb_resetwifi bash alias and entry in sb_tools to reset the pi to a hot spot and reselect your wifi.  Created a service that will set the timezone automatically based on your IP address

### Bug fixes

 - [`e09082e`](https://github.com/falkyre/nhl-led-portal-img/commits/e09082e) [stage2/04-scoreboard] Change .nhlupdate to .nhlledportal everywhere it's used.  Cleaned up issueUpload, checkUpdate scripts with shellcheck
 - [`0cd4705`](https://github.com/falkyre/nhl-led-portal-img/commits/0cd4705) [stage2/07-raspiwifi]  Disable the dnsmasq service after the hot spot sets up the wifi, renable on reset.  Tweak the dhcpcd.conf to only use ipv4 and remove the wait.conf so the boot doesn't wait for full network
 - [`3e3b5e5`](https://github.com/falkyre/nhl-led-portal-img/commits/3e3b5e5) [stage2/all]           Tweak for faster boots.  Remove connection_watcher.py when running normally, new splash.gif

### Other changes

 - [`aff2b1a`](https://github.com/falkyre/nhl-led-portal-img/commits/aff2b1a)                        Fix(stage2/04-scoreboard) add variables at start of 00-run.sh to choose repo and if you want beta
 - [`9e8f44b`](https://github.com/falkyre/nhl-led-portal-img/commits/9e8f44b)                        Fix(stage2/04-scoreboard) clean up some typos, add in the led-image-viewer so no need to compile it on build
 - [`c13e27b`](https://github.com/falkyre/nhl-led-portal-img/commits/c13e27b)                        Fix(stage2/04-scoreboard) updated splash.gih, modifed the runtext.py to center the text on the panel and to run it longer before exit
 - [`024d926`](https://github.com/falkyre/nhl-led-portal-img/commits/024d926)                        Fix(stage2/various) Typo in 00-run.sh in 07-raspiwifi.  Missing python3-cairo apr install in 04-scoreboard packages.  Fix get_version and tweaked the time for the splash screen to run
 - [`3c576b8`](https://github.com/falkyre/nhl-led-portal-img/commits/3c576b8)                        Merge branch 'master' of github.com:falkyre/nhl-led-portal-img
 - [`488b8e5`](https://github.com/falkyre/nhl-led-portal-img/commits/488b8e5)                        Update .bashrc and resize partition to include the isolcpus=3 for cmdline.txt

