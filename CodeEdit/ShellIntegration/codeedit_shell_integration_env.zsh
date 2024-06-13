# Modified from Microsoft's VSCode. MIT License.
# Permalink to original file:
# https://github.com/microsoft/vscode/blob/60d7343892f10e0c5f09cb55a6a3f268eb0dd4fb/src/vs/workbench/contrib/terminal/browser/media/shellIntegration-env.zsh

if [[ -f $USER_ZDOTDIR/.zshenv ]]; then
	CE_ZDOTDIR=$ZDOTDIR
	ZDOTDIR=$USER_ZDOTDIR

	# prevent recursion
	if [[ $USER_ZDOTDIR != $CE_ZDOTDIR ]]; then
		. $USER_ZDOTDIR/.zshenv
	fi

	USER_ZDOTDIR=$ZDOTDIR
	ZDOTDIR=$CE_ZDOTDIR
fi
