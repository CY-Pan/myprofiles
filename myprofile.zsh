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
		export https_proxy=http://localhost:8889 http_proxy=http://localhost:8889 all_proxy=socks5://localhost:8890
	;;
	esac
}

pipUpdate(){
	python3 -m pip install -U pip
	pipdeptree --warn silence | grep -E '^\w+' | cut -d = -f 1 | xargs pip3 install -U
	pip3 cache purge
}

brewUpdate(){
	brew update && brew upgrade && brew autoremove && brew cleanup -s
}

clearOldEdge(){
	cd ~/Library/Application\ Support/Microsoft/EdgeUpdater/apps/msedge-stable
	files=($(ls | sort -V))
	[[ ${#files} -gt 1 ]] && print "rm $files[1,-2]" && rm -fr $files[1,-2]
	cd -
}

alias git-shallone='git clone --depth 1'
alias rm='rm -i'
alias wget='curl -O'