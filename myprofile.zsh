proxy() {
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
		export https_proxy=http://localhost:8890 http_proxy=http://localhost:8890 all_proxy=socks5://localhost:8889
		;;
	esac
}

getSystemProxy() {
	networksetup -getwebproxy Wi-Fi
	networksetup -getsecurewebproxy Wi-Fi
	networksetup -getsocksfirewallproxy Wi-Fi
}

offSystemProxy() {
	networksetup -setwebproxystate Wi-Fi off
	networksetup -setsecurewebproxystate Wi-Fi off
	networksetup -setsocksfirewallproxystate Wi-Fi off
}

pipUpdate() {
	python3 -m pip install -U pip
	pipdeptree --warn silence | grep -E '^\w+' | cut -d = -f 1 | xargs pip3 install -U
	pip3 cache purge
}

brewUpdate() {
	brew update && brew upgrade && brew autoremove && brew cleanup -s
}

# clearOldEdge() {
# open ~/Library/Application\ Support/Microsoft/EdgeUpdater/apps/msedge-stable
# files=($(ls | sort -V)) &&
# [[ ${#files} -gt 1 ]] && echo "trash $files[1,-2]"
# }

gitResetRepoCommit() {
	if read -qs '?Are you sure to discard all commit historys? [y/N] '; then
		for branch in $(git branch -l); do
			git checkout $branch
			git reset --hard $(git commit-tree HEAD^{tree} -m 'Init commit')
		done
	else
		echo "\nAbort."
	fi
}

gitCheckAllBranch() {
	for branch in $(git branch -r | grep -v 'HEAD'); do
		git checkout ${branch##*/}
	done
}

gitGraph() {
	git log --all --graph --oneline
}

dYTvideo() {
	if [[ $# -ne 2 ]]; then
		echo "Usage: dYTvideo <URL> <CookieFile>"
		return 1
	fi
	yt-dlp --cookies $2 --merge-output-format mp4 $1
}

dYTaudio() {
	if [[ $# -ne 2 ]]; then
		echo "Usage: dYTaudio <URL> <CookieFile>"
		return 1
	fi
	yt-dlp --cookies $2 -f ba -x --audio-format mp3 $1
}

alias gitShallone='git clone --depth 1'
alias rm='echo Do not use rm. Use trash instead.; false'
alias wget='curl -O'
alias mk=make
alias op='open .'
