#Set the colors

NEWT_COLORS='
    root=green,black
    border=green,black
    title=green,black
    roottext=white,black
    window=green,black
    textbox=white,black
    button=black,green
    compactbutton=white,black
    listbox=white,black
    actlistbox=black,white
    actsellistbox=black,green
    checkbox=green,black
    actcheckbox=black,green
'
export NEWT_COLORS


if [ -t 1 ]; then
  RAINBOW=(
    "$(printf '\033[38;5;196m')"
    "$(printf '\033[38;5;202m')"
    "$(printf '\033[38;5;226m')"
    "$(printf '\033[38;5;082m')"
    "$(printf '\033[38;5;021m')"
    "$(printf '\033[38;5;093m')"
    "$(printf '\033[38;5;163m')"
  )

  RED=$(printf '\033[31m')
  GREEN=$(printf '\033[32m')
  YELLOW=$(printf '\033[33m')
  BLUE=$(printf '\033[34m')
  BOLD=$(printf '\033[1m')
  DIM=$(printf '\033[2m')
  UNDER=$(printf '\033[4m')
  RESET=$(printf '\033[m')
fi

# Aliases
# - sudo alias that allows running other aliases with "sudo": https://github.com/MichaIng/DietPi/issues/424
alias sudo='sudo '
# - Scoreboard programs
alias sb-help='/home/pi/sbtools/sb-help'
alias sb-issue='/home/pi/sbtools/issueUpload.sh 2>1'
alias sb-updatecheck='/home/pi/sbtools/checkUpdate.sh'
alias sb-stderr='supervisorctl tail -50000 scoreboard stderr'
alias sb-stdout='supervisorctl tail -50000 scoreboard'
alias sb-livelog='supervisorctl tail -f scoreboard'
alias sb-stop='supervisorctl stop scoreboard'
alias sb-start='supervisorctl start scoreboard'
alias sb-restart='supervisorctl restart scoreboard'
alias sb-status='supervisorctl status scoreboard'
alias sb-tools='/home/pi/sbtools/sb-tools'
alias sb-changelog='cd /home/pi/nhl-led-scoreboard;latest=$(git tag --sort=-v:refname | head -1);previous=$(git tag --sort=-v:refname | head -2 | tail -1);echo "$(tput bold)$(tput smul)Changes since $previous$(tput sgr0)";git log --oneline --decorate $previous..$latest;cd ~'
alias sb-sysinfo='neofetch --off'
alias sb-upgrade='/home/pi/sbtools/sb-upgrade'
alias sb-resetwifi='sudo /usr/sbin/comitup-cli d'

#Output sysinfo only if not the root user

if [ "$EUID" -ne 0 ]; then
   # Add in first run to force running the sb-tools to setup the board config
   if [ -f /home/pi/.nhlledportal/SETUP ]; then
        whiptail --msgbox "Welcome to the nhl-led-scoreboard initial setup. You will be asked to select a team and your board size for initial configuration.\n\nThis configuration will reboot after you do your setup.\n\nYou can do a more complex setup after by using the /home/pi/nhl-led-scoreboard/nhl_setup app after the reboot" 20 60 1
        /home/pi/sbtools/sb-tools do_firstrun
   fi
   neofetch --off
   #Check to see if there is an UPDATE and if there is, ask the user if they want to run it
   status=$(cat /home/pi/.nhlledportal/status)
   if [[ $status == *"New"* ]]; then
    while true; do
        read -p "$(tput bold)$(tput setaf 2)$(tput smso)$status $(tput rmso) Upgrade? (y/n)" yn
        case $yn in
           [Yy]* ) /home/pi/sbtools/sb-upgrade; break;;
           [Nn]* ) echo "You can update manually using the sb-upgrade tool"; break;;
            * ) echo "Please answer yes or no.";;
        esac
     done
   fi
   export PATH=/home/pi/nhl-led-scoreboard/venv/bin:$PATH
fi

_virtualenv_auto_activate() {
    have_not_found=true
    for folderName in $(find -maxdepth 1 -type d); do
        if [ -e "$folderName/bin/activate" ]; then
            have_not_found=false
            if [ "$VIRTUAL_ENV" = "" ]; then
                _VENV_NAME="venv $(basename `pwd`)"
#                echo Activating virtualenv \"$_VENV_NAME\"...
                VIRTUAL_ENV_DISABLE_PROMPT=1
                source $folderName/bin/activate
                _OLD_VIRTUAL_PS1="$PS1"
                PS1="${BLUE}[$_VENV_NAME]${RESET}$PS1"
                export PS1
            fi
        fi
    done
    if $have_not_found ; then
        if [ "$VIRTUAL_ENV" != "" ]; then
#            echo Deactivating Virtualenv...
            deactivate
        fi
    fi
}

export PROMPT_COMMAND=_virtualenv_auto_activate

function chpwd(){
    _virtualenv_auto_activate
}

_virtualenv_auto_activate