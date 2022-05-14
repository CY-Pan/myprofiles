function proxy{
	$Env:http_proxy="http://127.0.0.1:7890"
	$Env:https_proxy="http://127.0.0.1:7890"
}

function unproxy{
	ri Env:http_proxy
	ri Env:https_proxy
}

function showpath{
	(gc Env:path) -split ';' | tee -Variable tmp | measure && gv tmp -ValueOnly
}

function pathsearch($pattern){
	(gc Env:path) -split ';' -match $pattern
}

function pipupdate{
	pip list -o --format freeze | %{$_.split('==')[0]} | %{pip install -U $_}
	pip cache purge
}

function showSSHlogs($count=10){
	Get-WinEvent -Path $Env:SystemRoot\System32\Winevt\Logs\OpenSSH%4Operational.evtx -MaxEvents $count
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete