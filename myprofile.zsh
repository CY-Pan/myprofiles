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
	pip list -o --format freeze | cut -d = -f 1 | xargs pip install -U
	pip cache purge
}

brewupdate(){
	brew update && brew upgrade && brew autoremove && brew cleanup -s
}

alias git-shallone='git clone --depth 1'
