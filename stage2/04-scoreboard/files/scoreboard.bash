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
alias sb-resetwifi='sudo python3 /usr/lib/raspiwifi/reset_device/manual_reset.py'

#Output sysinfo only if not the root user

if [ $USER != "root" ]; then
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
fi
