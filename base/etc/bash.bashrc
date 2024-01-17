# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
# but only if not SUDOing and have SUDO_PS1 set; then assume smart user.
if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  PS1='${debian_chroot:+($debian_chroot)}\u@$APP_FQDN:\w\$ '
fi

# git branch msg
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1='\u@$APP_FQDN \[\e[32m\]\w \[\e[91m\]$(parse_git_branch)\[\e[00m\]\$ '

# Long format list
alias ll="ls -la"

# Print my public IP
alias mypublicip='curl ipinfo.io'

alias cpanm="cpanm --quiet --notest"

alias ligero-console='otrs.Console.pl'
alias ligero-daemon-summary='otrs.Console.pl Maint::Daemon::Summary'
alias ligero-email-mailqueue='otrs.Console.pl Maint::Email::MailQueue'
alias ligero-config-rebuild='otrs.Console.pl Maint::Config::Rebuild'
alias apt-install='sudo apt update && sudo apt install -y'

# Get path to current file, follow symlinks
THIS_FILE=$BASH_SOURCE
if [ -L $THIS_FILE ]; then
    THIS_FILE=`readlink $THIS_FILE`;
fi

# Remove : from wordbreak delimiter because OTRS uses it in the command names
COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

_console_complete()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ! -f /tmp/_console_complete ]; then
      /opt/otrs/bin/otrs.Console.pl | tr -d "[]" | grep '\- ' | cut -f 2 -d ' ' > /tmp/_console_complete
    fi;
    COMPREPLY=( $(cat /tmp/_console_complete | egrep --ignore-case "^$cur") )
}
complete -f -d -F _console_complete otrs.Console.pl

bind 'set completion-ignore-case on'
