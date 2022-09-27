proxy1(){
	export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
}

proxy2(){
	export https_proxy=socks5://127.0.0.1:8890 http_proxy=socks5://127.0.0.1:8890 all_proxy=socks5://127.0.0.1:8890
}

unproxy(){
	unset https_proxy http_proxy all_proxy
	export https_proxy http_proxy all_proxy
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
