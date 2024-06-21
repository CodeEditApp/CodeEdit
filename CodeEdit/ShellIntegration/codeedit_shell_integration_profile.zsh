# Modified from Microsoft's VSCode. MIT License.
# Permalink to original file:
# https://github.com/microsoft/vscode/blob/60d7343892f10e0c5f09cb55a6a3f268eb0dd4fb/src/vs/workbench/contrib/terminal/browser/media/shellIntegration-profile.zsh

if [[ -o "login" &&  -f $USER_ZDOTDIR/.zprofile ]]; then
	CE_ZDOTDIR=$ZDOTDIR
	ZDOTDIR=$USER_ZDOTDIR
	. $USER_ZDOTDIR/.zprofile
	ZDOTDIR=$CE_ZDOTDIR
fi
