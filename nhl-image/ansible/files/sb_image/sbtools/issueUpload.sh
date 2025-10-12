#!/bin/bash
# Upload the scoreboard stderr, stdout and config.json to pastebin using pastebinit

if command -v supervisorctl &> /dev/null
then
    SUPERVISOR_INSTALLED=true
else
    SUPERVISOR_INSTALLED=false
fi

if [ -n "${1}" ]; then
   scoreboard_proc=$1
else
   scoreboard_proc="scoreboard"
fi

#Create temp file with the data
ROOT=$(/usr/bin/dirname "$(/usr/bin/git rev-parse --git-dir)")
version=$(/bin/cat "${ROOT}"/VERSION)
currdate=$(date)
echo "nhl-led-scoreboard issue data ${currdate}" > /tmp/issue.txt
echo "=============================" >>/tmp/issue.txt
echo "" >> /tmp/issue.txt
echo "Running V${version} on a " >> /tmp/issue.txt
/usr/bin/fastfetch -l none  | grep Host >> /tmp/issue.txt
echo "Running OS: " >> /tmp/issue.txt
/usr/bin/fastfetch -l none  | grep "OS:" >> /tmp/issue.txt

echo "------------------------------------------------------" >> /tmp/issue.txt
echo "Git Remotes" >> /tmp/issue.txt
echo "=================================" >> /tmp/issue.txt
/usr/bin/git remote -v >> /tmp/issue.txt

echo "------------------------------------------------------" >> /tmp/issue.txt

VENV_EXISTS=false
if [ -d "$HOME/nhlsb-venv" ]; then
    echo "$HOME/nhlsb-venv ..... FOUND" >> /tmp/issue.txt
    VENV_EXISTS=true
else
    echo "$HOME/nhlsb-venv ..... NOT FOUND" >> /tmp/issue.txt
fi

if [ -d "$HOME/nhl-led-score-board" ]; then
    echo "$HOME/nhl-led-score-board ..... FOUND" >> /tmp/issue.txt
else
    echo "$HOME/nhl-led-score-board ..... NOT FOUND" >> /tmp/issue.txt
fi

if [ -d "$HOME/nhl-led-scoreboard/submodules/matrix/bindings/python" ]; then
    echo "$HOME/nhl-led-scoreboard/submodules/matrix/bindings/python ..... FOUND" >> /tmp/issue.txt
else
    echo "$HOME/nhl-led-scoreboard/submodules/matrix/bindings/python ..... NOT FOUND" >> /tmp/issue.txt
fi

if [ "$VENV_EXISTS" = true ]; then
    echo "------------------------------------------------------" >> /tmp/issue.txt
    echo "pip list" >> /tmp/issue.txt
    echo "=================================" >> /tmp/issue.txt
    source "$HOME/nhlsb-venv/bin/activate"
    pip list >> /tmp/issue.txt
    deactivate
fi

echo "------------------------------------------------------" >> /tmp/issue.txt
echo "config.json" >> /tmp/issue.txt
echo "" >>/tmp/issue.txt
/usr/bin/jq '.boards.weather.owm_apikey=""' "${ROOT}"/config/config.json >> /tmp/issue.txt
echo "" >> /tmp/issue.txt

if [ -f "$HOME/nhl-led-scoreboard/scoreboard.log" ]; then
    echo "------------------------------------------------------" >> /tmp/issue.txt
    echo "scoreboard.log" >> /tmp/issue.txt
    echo "=================================" >> /tmp/issue.txt
    cat "$HOME/nhl-led-scoreboard/scoreboard.log" >> /tmp/issue.txt
    SUPERVISOR_INSTALLED=true

    # We've read the log file, now delete it
    rm $HOME/nhl-led-scoreboard/scoreboard.log
fi

if [ "$SUPERVISOR_INSTALLED" = true ]; then
    echo "------------------------------------------------------" >> /tmp/issue.txt
    echo "supervisorctl status" >> /tmp/issue.txt
    echo "------------------------------------------------------" >> /tmp/issue.txt
    /usr/local/bin/supervisorctl status >>/tmp/issue.txt
    echo "------------------------------------------------------" >> /tmp/issue.txt
    echo "${scoreboard_proc} stderr log, last 50kb" >> /tmp/issue.txt
    echo "=================================" >> /tmp/issue.txt
    /usr/local/bin/supervisorctl tail -50000 $scoreboard_proc stderr >> /tmp/issue.txt
    echo "" >> /tmp/issue.txt
    echo "------------------------------------------------------" >> /tmp/issue.txt
    echo "${scoreboard_proc} stdout log, last 50kb" >> /tmp/issue.txt
    echo "=================================" >> /tmp/issue.txt
    /usr/local/bin/supervisorctl tail -50000 $scoreboard_proc >> /tmp/issue.txt
fi

if [ "$SUPERVISOR_INSTALLED" = false ]; then
    echo "supervisorctl not found. Please run the scoreboard with the --logtofile and the --loglevel=DEBUG option to generate a scoreboard.log. Once the issue happens again, rerun this script"
else
    url=$(/usr/bin/pastebinit -b pastebin.com -t "nhl-led-scoreboard issue logs and config" < /tmp/issue.txt)
    echo "Take this url and paste it into your issue.  You can create an issue @ https://github.com/falkyre/nhl-led-scoreboard/issues"
    echo "${url}"
fi


rm /tmp/issue.txt
