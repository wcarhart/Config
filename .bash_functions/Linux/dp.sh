# cycle through different prompts (different PS1 variables)
dp() {
	if [[ $# -eq 0 ]] ; then
		# default
		export __PS1__=''
	elif [[ "$1" == "1" ]] ; then
		# minimalist
		export __PS1__="\\$ "
	elif [[ "$1" == "2" ]] ; then
		# just date
		export __PS1__="[\A] > "
	elif [[ "$1" == "3" ]] ; then
		# full date and pwd
		export __PS1__="[\u@\h] \d, \T <\W> \\$ "
	elif [[ "$1" == "4" ]] ; then
		# mood based on last command
		export __PS1__="\`if [ \$? = 0 ]; then echo \[\e[33m\]^_^\[\e[0m\]; else echo \[\e[31m\]O_O\[\e[0m\]; fi\` \\$ "
	else
		echo "dp: err: invalid prompt index, must be [1,4]"
		return 1
	fi
}
