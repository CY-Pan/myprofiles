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
		gci | sort LastWriteTime -Descending
	}else{
		gci | sort LastWriteTime
	}
}

function du($dir='.'){
	gci $dir -Recurse -Force | measure -Property Length -Sum
}

function pipUpdate{
	python -m pip install -U pip
	(pipdeptree --warn silence) -match '^\w+' | %{$_.split('==')[0]} | %{pip install -U $_}
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

function addRegistryLocations(){
	if(!(Test-Path HKCR:)){ ndr -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR -Scope Global }
	if(!(Test-Path HKCU:)){ ndr -PSProvider Registry -Root HKEY_CURRENT_USER -Name HKCU -Scope Global }
	if(!(Test-Path HKLM:)){ ndr -PSProvider Registry -Root HKEY_LOCAL_MACHINE -Name HKLM -Scope Global }
	if(!(Test-Path HKU:)) { ndr -PSProvider Registry -Root HKEY_USERS -Name HKU -Scope Global }
	if(!(Test-Path HKCC:)){ ndr -PSProvider Registry -Root HKEY_CURRENT_CONFIG -Name HKCC -Scope Global }
}

function newRegistryItemForOpen(){
	Param(
		[Parameter(Mandatory)][string]$Ext,
		[Parameter(Mandatory)][string]$Program,
		[Parameter(Mandatory)][string]$IconPath
	)

	ni ".$($Ext)_auto_file"
	ni ".$($Ext)_auto_file\DefaultIcon"
	ni ".$($Ext)_auto_file\shell"
	ni ".$($Ext)_auto_file\shell\open"
	ni ".$($Ext)_auto_file\shell\open\command"

	sp ".$($Ext)_auto_file\DefaultIcon" -Name '(default)' -Value $IconPath
	sp ".$($Ext)_auto_file\shell\open" -Name '(default)' -Value """$Program"""
	sp ".$($Ext)_auto_file\shell\open\command" -Name '(default)' -Value """$Program"" ""%1"""
}

function downloadYTaudio($URL){
	yt-dlp -f ba -x --audio-format mp3 $URL
}

function downloadYTvideo($URL){
	yt-dlp --merge-output mp4 $URL
}

sal open -Value explorer

if(!(Test-Path Env:SSH_CONNECTION) -or (Test-Path Env:SSH_TTY)){
	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

	if(Test-Path Env:SSH_CONNECTION){ write "Hello, remote client from $($Env:SSH_CLIENT)." }
}
