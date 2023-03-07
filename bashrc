# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*.conf; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

# Get BibTex from DOI
getdoi() {
    ENTRY=`/usr/bin/curl -s -L -H "Accept: text/bibliography; style=bibtex" -A "mailto:myemail@domain.com" https://doi.org/$1`
    echo $ENTRY
    echo "\n"
    echo $ENTRY | /usr/bin/bibtool
}

# . "$HOME/.cargo/env"
