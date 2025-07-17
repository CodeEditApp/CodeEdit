#  codeedit-shell_Integration_rc.zsh
#  CodeEdit
#
#  Created by Qian Qian "Cubik" (@Cubik65536) on 2023-06-13.
#
#  This script is used to configure zsh/OhMyZsh shells
#  so the terminal title would be set properly
#  with shell name or program's command name
#

# Parts of this file contain modified versions of a source file from Microsoft's VSCode. MIT License.
# Permalink to original file:
# https://github.com/microsoft/vscode/blob/60d7343892f10e0c5f09cb55a6a3f268eb0dd4fb/src/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh

# BEGIN: Modified Microsoft code

# Prevent the script recursing when setting up
if [ -n "$CE_SHELL_INTEGRATION" ]; then
	ZDOTDIR=$USER_ZDOTDIR
	builtin return
fi

# This variable allows the shell to both detect that VS Code's shell integration is enabled as well
# as disable it by unsetting the variable.
CE_SHELL_INTEGRATION=1

# By default, zsh will set the $HISTFILE to the $ZDOTDIR location automatically. In the case of the
# shell integration being injected, this means that the terminal will use a different history file
# to other terminals. To fix this issue, set $HISTFILE back to the default location before ~/.zshrc
# is called as that may depend upon the value.
if [[ "$CE_INJECTION" == "1" ]]; then
	HISTFILE=$USER_ZDOTDIR/.zsh_history
fi

# Only fix up ZDOTDIR if shell integration was injected (not manually installed) and has not been called yet
if [[ "$CE_INJECTION" == "1" ]]; then
	if [[ -f $USER_ZDOTDIR/.zshrc ]]; then
		CE_ZDOTDIR=$ZDOTDIR
		ZDOTDIR=$USER_ZDOTDIR
		# A user's custom HISTFILE location might be set when their .zshrc file is sourced below
		. $USER_ZDOTDIR/.zshrc
	fi
fi

# END: Microsoft code

builtin autoload -Uz add-zsh-hook

__codeedit_preexec() {
    builtin printf "\033]0;%s\007" "$1"
}

__codeedit_precmd() {
    builtin printf "\033]0;zsh\007"
}

add-zsh-hook preexec __codeedit_preexec
add-zsh-hook precmd __codeedit_precmd

if [[ "$CE_DISABLE_HISTORY" == "1" ]]; then
    unset HISTFILE
fi

# Fix ZDOTDIR

if [[ $USER_ZDOTDIR != $CE_ZDOTDIR ]]; then
	ZDOTDIR=$USER_ZDOTDIR
fi
