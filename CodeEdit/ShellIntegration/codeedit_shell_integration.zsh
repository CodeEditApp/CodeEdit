#!/bin/zsh

#  codeedit-shell_Integration.zsh
#  CodeEdit
#
#  Created by Qian Qian "Cubik" (@Cubik65536) on 2023-06-13.
#
#  This script is used to configure zsh/OhMyZsh shells
#  so the terminal title would be setted properly
#  with shell name or program's command name
#

autoload -Uz add-zsh-hook

__codeedit_preexec() {
    echo -n "\033]0;${1}\007"
}

__codeedit_precmd() {
    echo -n "\033]0;zsh\007"
}

add-zsh-hook preexec __codeedit_preexec
add-zsh-hook precmd __codeedit_precmd
