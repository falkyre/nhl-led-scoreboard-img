#!/bin/bash

CURRENTLY_BUILT_VER=`cat /home/pi/nhl-led-scoreboard/VERSION` # stored somewhere, e.g. spec file in my case
LASTVER=$(lastversion riffnshred/nhl-led-scoreboard -gt ${CURRENTLY_BUILT_VER})
if [[ $? -eq 0 ]]; then
  # LASTVER is newer, update and trigger build
  # ....
  echo "New version available!!"

else
  echo "You are running the latest version ${CURRENTLY_BUILT_VER}"
fi
