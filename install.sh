# set cleanup trap
trap cleanup EXIT
mkdir ~/.originals

# detect os type
ostype() {
    OS=`uname -s`
    case "${OS}" in
        Linux*)     MACHINE=Linux   ;;
        Darwin*)    MACHINE=MacOS   ;;
        CYGWIN*)    MACHINE=Cygwin  ;;
        MINGW*)     MACHINE=MinGw   ;;
        *)          MACHINE=UNKNOWN ;;
    esac
    echo "$MACHINE"
}

# trap
function cleanup {
	if [[ -d ~/.originals ]] ; then
		for FILE in ~/.originals/* ; do
			yes | cp -rf $FILE ~ >/dev/null 2>&1
		done
		rm -rf ~/.originals
		echo "Error: installation failed! Please review the ~/Konphig source repo and reclone it, if necessary"
		exit 1
	else
		if [[ "$OS" == "MacOS" ]] ; then
			echo -n "source ~/.bashrc" | pbcopy
		fi
		echo "Setup successful!"
		echo "To complete installation, please run:"
		printf "  \033[93msource ~/.bashrc\033[0m"
		if [[ "$OS" == "MacOS" ]] ; then
			printf " (\033[35mpress ⌘ + V\033[0m)\n"
		else
			echo
		fi
		exit 0
	fi
}

# parse command line arguments
DEPS=0
if [[ "$1" == "-d" || "$1" == "--install-dependencies" ]] ; then
	DEPS=1
fi

# validate inputs and settings
OS=`ostype`
if [[ "`basename $SHELL`" != "bash" ]] ; then
	echo "Error: Konphig is not supported for this shell"
	exit 1
fi
if [[ ! -f /bin/bash ]] && [[ ! -L /bin/bash ]] ; then
	echo "Error: could not find Bash at /bin/bash"
	echo "Use the following to link Bash to /bin/bash, and then try installing again:"
	echo "  ln -sf bash /bin/bash"
	exit 1
fi
if [[ $OS != "Linux" && $OS != "MacOS" ]] ; then
	echo "Error: Konphig is not supported for this OS"
	exit 1
fi
if [[ ! -d ~/Konphig ]] ; then
	echo "Error: missing directory ~/Konphig"
	exit 1
fi
if [[ ! -d ~/Konphig/.bash_functions ]] ; then
	echo "Error: missing directory ~/Konphig/.bash_functions"
	exit 1
fi
if [[ ! -d ~/Konphig/.bash_functions/$OS ]] ; then
	echo "Error: missing directory ~/Konphig/.bash_functions/$OS"
	exit 1
fi
if [[ ! -f ~/Konphig/.bash_functions/$OS/dependencies.txt ]] ; then
	echo "Error: missing dependency file ~/Konphig/.bash_functions/$OS/dependencies.txt"
	exit 1
fi

# create backup
if [[ -f ~/.bashrc ]] ; then
	mv ~/.bashrc ~/.originals/
fi
if [[ -f ~/.bash_profile ]] ; then
	mv ~/.bash_profile ~/.originals/
fi
if [[ -f ~/.git-prompt.sh ]] ; then
	mv ~/.git-prompt.sh ~/.originals/
fi
if [[ -f ~/.gitconfig ]] ; then
	mv ~/.gitconfig ~/.originals/
fi
if [[ -f ~/.profile ]] ; then
	mv ~/.profile ~/.originals/
fi
if [[ -f ~/.tmux.conf ]] ; then
	mv ~/.tmux.conf ~/.originals/
fi
if [[ -f ~/.vimrc ]] ; then
	mv ~/.vimrc ~/.originals/
fi
if [[ -f ~/.pypirc ]] ; then
	mv ~/.pypirc ~/.originals/
fi
if [[ -f ~/gpg-agent.conf ]] ; then
	mv ~/gpg-agent.conf ~/.originals/
fi

# begin installation
yes | cp -rf ~/Konphig/.bash_aliases ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/.bash_variables ~ >/dev/null 2>&1
mkdir -p ~/.bash_functions
for FILE in ~/Konphig/.bash_functions/$OS/* ; do
	yes | cp -rf $FILE ~/.bash_functions/ >/dev/null 2>&1
done
yes | cp -rf ~/Konphig/.bash_profile ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/.bashrc ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/.git-prompt.sh ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/.gitconfig ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/.profile ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/.tmux.conf ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/.vimrc ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/.pypirc ~ >/dev/null 2>&1
yes | cp -rf ~/Konphig/gpg-agent.conf ~ >/dev/null 2>&1

# set environment variables
export __UPDIR__=""

# install dependencies
if [[ $DEPS -eq 1 ]] ; then
	INSTALL=""
	if [[ "$OS" == "Linux" ]] ; then
		if [[ "`command -v yum 2>&1 /dev/null`" != "" ]] ; then
			INSTALL="yum install -y -q"
		elif [[ "`command -v apt-get 2>&1 /dev/null`" != "" ]] ; then
			INSTALL="apt-get install -y -q"
		fi
	else
		INSTALL="brew install"
	fi

	echo "Processing dependencies with `echo $INSTALL | awk '{print $1}'`..."

	if [[ "$INSTALL" == "" || "`command -v $INSTALL 2>&1 /dev/null`" == "" ]] ; then
		echo "Warning: could not find installation tool `echo $INSTALL | awk '{print $1}'`"
		echo "The following dependencies were not installed:"
		while IFS= read -r LINE || [[ -n "$LINE" ]] ; do
    		echo "  $LINE"
		done < ~/Konphig/.bash_functions/$OS/dependencies.txt
	else
		while IFS= read -r LINE || [[ -n "$LINE" ]] ; do
			if [[ `command -v $LINE` == "" ]] ; then
				echo "  Couldn't find $LINE. Attempting to install..."
				SILENCEOUT=`command $INSTALL $LINE 2>&1 /dev/null`
				if [[ $? -ne 0 ]] ; then
					echo "  Warning: could not install dependency $LINE, you may have to install it manually."
				else
					echo "  Successfully installed $LINE"
				fi
			fi  
		done < ~/Konphig/.bash_functions/$OS/dependencies.txt
	fi
fi

rm -rf ~/.originals