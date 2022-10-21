proxy(){
	set=${1:-1}
	case $set in
	0)
		unset https_proxy http_proxy all_proxy
		export https_proxy http_proxy all_proxy
	;;
	1)
		export https_proxy=http://localhost:7890 http_proxy=http://localhost:7890 all_proxy=socks5://localhost:7890
	;;
	2)
		export https_proxy=socks5://localhost:8890 http_proxy=socks5://localhost:8890 all_proxy=socks5://localhost:8890
	;;
	esac
}

pipupdate(){
	pip3 install -U pip
	pipdeptree --warn silence | grep -E '^\w+' | cut -d = -f 1 | xargs pip3 install -U
	pip3 cache purge
}

brewupdate(){
	brew update && brew upgrade && brew autoremove && brew cleanup -s
}

alias git-shallone='git clone --depth 1'
