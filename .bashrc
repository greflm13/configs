#
# ~/.bashrc
#

[[ $- != *i* ]] && return

if ! [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
        git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
        make -C /tmp/ble.sh install PREFIX=~/.local
        touch "$HOME/.blerc"
fi

[[ $- == *i* ]] &&
  source "$HOME/.local/share/blesh/ble.sh" --rcfile "$HOME/.blerc" --noattach

export PATH="${HOME}/.local/bin:$PATH"
export VISUAL=vim
export EDITOR="$VISUAL"
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL="erasedups"

[[ -f ~/.colorscripts ]] && source ~/.colorscripts

if [[ ${EUID} != 0 ]]; then
        if command -v "uwufetch" >/dev/null; then
                uwufetch
        elif command -v "rsfetch" >/dev/null; then
                rsfetch -PdehrlksuN
        elif command -v "pfetch" >/dev/null; then
                pfetch
        elif command -v "ufetch" >/dev/null; then
                ufetch
        elif command -v "neofetch" >/dev/null; then
                neofetch
        elif command -v "screenfetch" >/dev/null; then
                screenfetch
        fi
        [[ -f ~/.colorscripts ]] && colorpanes
fi

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
xterm* | rxvt* | Eterm* | aterm | kterm | gnome* | interix | konsole*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
        ;;
screen*)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
        ;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?} # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs} ]] &&
        type -P dircolors >/dev/null &&
        match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color}; then
        # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
        if type -P dircolors >/dev/null; then
                if [[ -f ~/.dir_colors ]]; then
                        eval "$(dircolors -b ~/.dir_colors)"
                elif [[ -f /etc/DIR_COLORS ]]; then
                        eval "$(dircolors -b /etc/DIR_COLORS)"
                fi
        fi

        if [[ ${EUID} == 0 ]]; then
                PS1='\[\033[1;31m\]\u@\h\[\033[0m\]:\[\033[34m\]\w\[\033[0m\]\$ '
        else
                PS1='\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[34m\]\w\[\033[0m\]\$ '
        fi

        alias ls='ls --color=auto'
        alias grep='grep --colour=auto'
        alias egrep='egrep --colour=auto'
        alias fgrep='fgrep --colour=auto'
        alias ip='ip -c'
        alias icat='icat -m both'
        alias diff='diff --color=auto'
        if command -v "eza" >/dev/null; then
                alias ll='eza -la --icons'
                alias l='eza -l --icons'
                alias tree='eza -Tl --icons'
        elif command -v "exa" >/dev/null; then
                alias ll='exa -la --icons'
                alias l='exa -l --icons'
                alias tree='exa -Tl --icons'
        else
                alias ll='ls -lAh --color=auto'
        fi
        if command -v "batcat" >/dev/null; then
                alias bat='batcat'
        fi

else
        if [[ ${EUID} == 0 ]]; then
                # show root@ when we don't have colors
                PS1='\u@\h \W \$ '
        else
                PS1='\u@\h \w \$ '
        fi
fi

unset use_color safe_term match_lhs sh

alias cp="cp -i"     # confirm before overwriting something
alias free='free -h'
alias more=less
alias fuck='sudo $(fc -ln -1)'
alias please='sudo'
alias df='df -Th'
command -v uwuify >/dev/null && alias uwu='uwuify' && alias uwuptime='uptime | uwuify'
alias pray='git commit -m "🙏"'
alias gitdir='cd ${HOME}/git'
command -v lxc >/dev/null && alias lxl='lxc list -c ns46u,limits.cpu:cpu,m,limits.memory:MEMORY,D,config:image.os,config:image.release'

# gitdirs
for server in "${HOME}"/git/*; do
        if [ -d "$server" ]; then
                serverdir=$(basename "$server")
                serverdir=${serverdir// /_}
                alias "${serverdir%.*}"="cd $server"
        fi
done

xhost +local:root >/dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize
shopt -s expand_aliases
shopt -s histappend
shopt -s extglob

extract() {
        local c e i

        (($#)) || return

        for i; do
                c=''
                e=1

                if [[ ! -r $i ]]; then
                        echo "$0: file is unreadable: \`$i'" >&2
                        continue
                fi

                case $i in
                *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                        c=(bsdtar xvf)
                        ;;
                *.7z) c=(7z x) ;;
                *.Z) c=(uncompress) ;;
                *.bz2) c=(bunzip2) ;;
                *.exe) c=(cabextract) ;;
                *.gz) c=(gunzip) ;;
                *.rar) c=(unrar x) ;;
                *.xz) c=(unxz) ;;
                *.zip) c=(unzip -d "${i%.zip}") ;;
                *.zst) c=(unzstd) ;;
                *)
                        echo "$0: unrecognized file extension: \`$i'" >&2
                        continue
                        ;;
                esac

                command "${c[@]}" "$i"
                ((e = e || $?))
        done
        return "$e"
}

mkcd() {
        mkdir "$1" && cd "$1" || return
}

dc() {
        local dir="$1"
        local dir="${dir:=$HOME}"
        if [[ -d "${dir}" ]]; then
                cd "${dir}" >/dev/null || return
                ll
        else
                echo "bash: dc: $dir: Directory not found"
        fi
}

ipif() {
        curl ipinfo.io
        echo
}

note() {
        # if file doesn't exist, create it
        if [[ ! -f $HOME/.notes ]]; then
                touch "$HOME/.notes"
        fi

        if ! (($#)); then
                # no arguments, print file
                cat "$HOME/.notes"
        elif [[ "$1" == "-c" ]]; then
                # clear file
                printf "" >"$HOME/.notes"
        else
                # add all arguments to file
                printf "%s\n" "- $*" >>"$HOME/.notes"
        fi
}

gitclone() {
        sshre='.*@(.*):[0-9]*(.*)\/(.*)\.git'
        httpre='https?:\/\/(.*)\/(.*)\/(.*).git\/?'
        if [[ $1 =~ $sshre ]]; then
                mkdir -p "$HOME"/git/"${BASH_REMATCH[1]}"/"${BASH_REMATCH[2]}"
                git clone "$1" "$HOME"/git/"${BASH_REMATCH[1]}"/"${BASH_REMATCH[2]}"/"${BASH_REMATCH[3]}"
        fi
        if [[ $1 =~ $httpre ]]; then
                mkdir -p "$HOME"/git/"${BASH_REMATCH[1]}"
                git clone "$1" "$HOME"/git/"${BASH_REMATCH[1]}"/"${BASH_REMATCH[2]}"/"${BASH_REMATCH[3]}"
        fi
}

gitpull() {
        dir=$(pwd)
        for folder in $(find "$HOME/git" -name ".git" -type d | sort | sed 's|/\.git||g'); do
                cd "${folder}" || return
                echo -e "\033[1;34m$(pwd | sed "s%$HOME/git/%%g")\033[0m"
                git pull
        done
        cd "${dir}" || return
}

gitdiff() {
        dir=$(pwd)
        for folder in $(find "$HOME/git" -name ".git" -type d | sort | sed 's|/\.git||g'); do
                cd "${folder}" || return
                git diff
        done
        cd "${dir}" || return
}

gitreset() {
        dir=$(pwd)
        for folder in $(find "$HOME/git" -name ".git" -type d | sort | sed 's|/\.git||g'); do
                cd "${folder}" || return
                git reset --hard
        done
        cd "${dir}" || return
}

gitblame() {
        dir=$(pwd)
        for folder in $(find "$HOME/git" -name ".git" -type d | sort | sed 's|/\.git||g'); do
                cd "${folder}" || return
                pwd | sed "s%$HOME/git/%%g"
                git log --author="$1"
                echo ""
        done
        cd "${dir}" || return
}

up() {
        bef=""
        if command -v pacman >/dev/null; then
                if command -v paru >/dev/null; then
                        bef+="paru -Syu --noconfirm --removemake; "
                elif command -v yay >/dev/null; then
                        bef+="yay -Syu --noconfirm --removemake; "
                else
                        bef+="sudo pacman -Syu --noconfirm; "
                fi
        fi
        command -v apt >/dev/null && bef+="sudo apt update; sudo apt dist-upgrade -y; sudo apt autoremove -y; "
        command -v flatpak >/dev/null && bef+="flatpak update -y; "
        command -v snap >/dev/null && bef+="sudo snap refresh; "
        eval "${bef}"
}

delete-orphans() {
        if command -v pacman >/dev/null; then
                if command -v paru >/dev/null; then
                        if paru -Qtdq; then
                                paru -Qtdq | paru -Rns --noconfirm -
                        fi
                elif command -v yay >/dev/null; then
                        if yay -Qtdq; then
                                yay -Qtdq | yay -Rns --noconfirm -
                        fi
                else
                        if sudo pacman -Qtdq; then
                                sudo pacman -Qtdq | sudo pacman -Rns --noconfirm -
                        fi
                fi
        fi
}

case ${TERM} in
xterm* | rxvt* | Eterm* | aterm | kterm | gnome* | interix | konsole* | alacritty)
        [[ -f ~/.pureline.conf ]] && source ~/.pureline/pureline ~/.pureline.conf
        ;;
esac

[[ ${BLE_VERSION-} ]] && ble-attach

command -v 1password >/dev/null && export SSH_AUTH_SOCK=~/.1password/agent.sock

NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"

# Preserve MANPATH if you already defined it somewhere in your config.
# Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

export GOPATH="${HOME}/.go"
export PATH="$PATH:$GOPATH"

[[ -f /opt/asdf-vm/asdf.sh ]] && . /opt/asdf-vm/asdf.sh

export GPG_TTY=$(tty)

# pyenv
if [ -d "${HOME}/.pyenv" ]; then
        case ":${PATH}:" in
    *:"$HOME/.pyenv/bin":*)
      ;;
    *)
      # Prepending path in case a system-installed binary needs to be overridden
      export PATH="$HOME/.pyenv/bin:$PATH"
      ;;
  esac
fi

if command -v pyenv >/dev/null; then
        export PYENV_ROOT="$HOME/.pyenv"
        [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
fi

# pnpm
export PNPM_HOME="${HOME}/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# nvm end

# Add scripts to PATH
[ -d "${HOME}/scripts" ] && export PATH="${HOME}/scripts:$PATH"

# Load Angular CLI autocompletion.
if command -v ng >/dev/null; then
        source <(ng completion script)
fi

# atuin
if [ -d "${HOME}/.atuin" ]; then
        case ":${PATH}:" in
                *:"$HOME/.atuin/bin":*)
                        ;;
                *)
                        # Prepending path in case a system-installed binary needs to be overridden
                        export PATH="$HOME/.atuin/bin:$PATH"
                        ;;
        esac
fi

if command -v atuin >/dev/null; then
        eval "$(atuin init bash)"
fi
