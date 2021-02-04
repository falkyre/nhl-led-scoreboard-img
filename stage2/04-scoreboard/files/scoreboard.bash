# Aliases
# - sudo alias that allows running other aliases with "sudo": https://github.com/MichaIng/DietPi/issues/424
alias sudo='sudo '
# - Scoreboard programs
alias sb-help='echo "$(tput smul)scoreboard commands:$(tput rmul) $(tput bold)sb-tools sb-issue sb-updatecheck sb-changelog sb-stderr sb-stdout sb-livelog sb-stop sb-start sb-restart sb-status sb-sysinfo$(tput sgr0)"'
alias sb-issue='/home/pi/sbtools/issueUpload.sh 2>1'
alias sb-updatecheck='/home/pi/sbtools/checkUpdate.sh'
alias sb-stderr='supervisorctl tail -50000 scoreboard stderr'
alias sb-stdout='supervisorctl tail -50000 scoreboard'
alias sb-livelog='supervisorctl tail -f scoreboard'
alias sb-stop='supervisorctl stop scoreboard'
alias sb-start='supvisorctl start scoreboard'
alias sb-restart='supervisorctl restart scoreboard'
alias sb-status='supervisorctl status scoreboard'
alias sb-tools='/home/pi/sbtools/sb-tools'
alias sb-changelog='cd /home/pi/nhl-led-scoreboard;latest=$(git tag --sort=-v:refname | head -1);previous=$(git tag --sort=-v:refname | head -2 | tail -1);echo "$(tput bold)$(tput smul)Changes since $previous$(tput sgr0)";git log --oneline --decorate $previous..$latest;cd ~'
alias sb-sysinfo='neofetch --off'

#Output sysinfo only if not the root user

if [ $USER != "root" ]; then
   neofetch --off
fi
