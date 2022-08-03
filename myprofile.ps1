function proxy1{
	$Env:http_proxy="http://127.0.0.1:7890"
	$Env:https_proxy="http://127.0.0.1:7890"
}

function proxy2{
	$Env:http_proxy="socks5://127.0.0.1:8890"
	$Env:https_proxy="socks5://127.0.0.1:8890"
}

function unproxy{
	ri Env:http_proxy
	ri Env:https_proxy
}

function showPath($pattern){
	$tmp = $Env:path -split ';' -match $pattern
	$tmp | measure -Line
	gv tmp -ValueOnly
}

function lt([switch]$Descending){
	if($Descending.IsPresent){
		ls | sort LastWriteTime -Descending
	}else{
		ls | sort LastWriteTime
	}
}

function du($dir='.'){
	gci $dir -Recurse -Force | measure -Property Length -Sum
}

function pipUpdate{
	pip list -o --format freeze | %{$_.split('==')[0]} | %{pip install -U $_}
	pip cache purge
}

function showSSHlogs($count=10){
	Get-WinEvent -Path $Env:SystemRoot\System32\Winevt\Logs\OpenSSH%4Operational.evtx -MaxEvents $count
}

function getHistory($count=50){
	gc (Get-PSReadlineOption).HistorySavePath -Tail $count
}

function su{
	saps wt -Verb RunAs
}

function git-shallone($repo){
	git clone $repo --depth 1
}

sal open -Value explorer

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
