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
	brew update && brew upgrade -y && brew autoremove && brew cleanup -s
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

# 批量清理 N 天前未更新的本地分支
# 用法: clean-old-branches 90
cleanOldBranches() {
	local days="${1:-90}"
	local cutoff
	cutoff=$(date -v-"${days}"d +%Y-%m-%d 2>/dev/null)
	if [ -z "$cutoff" ]; then
		echo "错误：无效的天数参数：$days"
		return 1
	fi

	# 确保在 git 仓库内
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		echo "错误：当前目录不是 git 仓库"
		return 1
	fi

	local current_branch
	current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")

	echo "==> 筛选 ${days} 天前（${cutoff} 之前）最后提交的本地分支..."
	echo ""

	# 列出符合条件的分支（排除当前分支和主分支）
	local old_branches
	old_branches=$(git for-each-ref --sort=committerdate refs/heads/ \
		--format='%(committerdate:short) %(refname:short)' | \
		awk -v cutoff="$cutoff" '$1 < cutoff {print $2}' | \
		grep -v -E '^(main|master|develop|dev|release)$' | \
		grep -v "^${current_branch}$")

	if [ -z "$old_branches" ]; then
		echo "没有找到符合条件的旧分支，无需清理。"
		return 0
	fi

	# 带时间完整展示
	echo "以下分支将被删除："
	echo "----------------------------------------"
	echo "$old_branches" | while read -r b; do
		local d
		d=$(git log -1 --format='%ci' "$b" 2>/dev/null | cut -d' ' -f1)
		printf "  %-12s %s\n" "$d" "$b"
	done
	echo "----------------------------------------"
	echo "共 $(echo "$old_branches" | wc -l | tr -d ' ') 个分支（当前分支与 main/master/develop 已自动排除）"
	echo ""

	# 交互确认
	local answer
	read -q "answer?确认删除以上分支？(y/N) "
	echo ""
	if [[ "$answer" != "y" ]]; then
		echo "已取消，未删除任何分支。"
		return 0
	fi

	# 执行删除（-d 安全删除，未合并的会被跳过并提示）
	echo ""
	echo "==> 开始删除..."
	local failed=()
	while IFS= read -r b; do
		[ -z "$b" ] && continue
		if git branch -d "$b" 2>/dev/null; then
		echo "  ✓ 已删除: $b"
		else
		echo "  ✗ 跳过(未合并): $b （如需强制删除请手动执行: git branch -D $b）"
		failed+=("$b")
		fi
	done <<< "$old_branches"

	echo ""
	echo "==> 完成。"
	if [ ${#failed[@]} -gt 0 ]; then
		echo "以下分支因未合并未被删除："
		printf '  %s\n' "${failed[@]}"
	fi
}


alias gitShallone='git clone --depth 1'
alias rm='echo Do not use rm. Use trash instead.; false'
alias wget='curl -O'
alias mk=make
alias op='open .'
