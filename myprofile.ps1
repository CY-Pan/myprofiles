function proxy($set=1){
	switch($set){
		0 { ri Env:http_proxy
			ri Env:https_proxy }
		1 { $Env:http_proxy='http://localhost:7890'
			$Env:https_proxy='http://localhost:7890' }
		2 { $Env:http_proxy='http://localhost:8889'
			$Env:https_proxy='http://localhost:8889' }
	}
}

function showPath($pattern){
	$tmp = $Env:path -split ';' -match $pattern
	$tmp | measure -Line
	gv tmp -ValueOnly
}

function lt([switch]$Descending){
	if($Descending.IsPresent){ gci | sort LastWriteTime -Descending }
	else{ gci | sort LastWriteTime }
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

function git-shallone([Parameter(Mandatory)]$repo){
	git clone $repo --depth 1
}

function addRegistryLocations(){
	if(!(Test-Path HKCR:)){ ndr -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR -Scope Global }
	if(!(Test-Path HKCU:)){ ndr -PSProvider Registry -Root HKEY_CURRENT_USER -Name HKCU -Scope Global }
	if(!(Test-Path HKLM:)){ ndr -PSProvider Registry -Root HKEY_LOCAL_MACHINE -Name HKLM -Scope Global }
	if(!(Test-Path HKU:)) { ndr -PSProvider Registry -Root HKEY_USERS -Name HKU -Scope Global }
	if(!(Test-Path HKCC:)){ ndr -PSProvider Registry -Root HKEY_CURRENT_CONFIG -Name HKCC -Scope Global }
}

function newRegistryItemForOpen([Parameter(Mandatory)][string]$Ext,
		[Parameter(Mandatory)][string]$Program,	[Parameter(Mandatory)][string]$IconPath){
	ni ".$($Ext)_auto_file"
	ni ".$($Ext)_auto_file\DefaultIcon"
	ni ".$($Ext)_auto_file\shell"
	ni ".$($Ext)_auto_file\shell\open"
	ni ".$($Ext)_auto_file\shell\open\command"

	sp ".$($Ext)_auto_file\DefaultIcon" -Name '(default)' -Value $IconPath
	sp ".$($Ext)_auto_file\shell\open" -Name '(default)' -Value """$Program"""
	sp ".$($Ext)_auto_file\shell\open\command" -Name '(default)' -Value """$Program"" ""%1"""
}

function dYTaudio([Parameter(Mandatory)]$URL){
	yt-dlp -f ba -x --audio-format mp3 $URL
}

function dYTvideo([Parameter(Mandatory)]$URL){
	yt-dlp --merge-output-format mp4 $URL
}

function ft([Parameter(Mandatory,ValueFromPipeline)]$table){
	$table | Format-Table -Wrap
}

function find([Parameter(Mandatory)]$path, [Parameter(Mandatory)]$name){
	gci $path -Recurse -Force -Include $name
}

function ln([Parameter(Mandatory)]$src, [Parameter(Mandatory)]$linkpath){
	ni -ItemType SymbolicLink -Target $src $linkpath
}

function recycle([Parameter(Mandatory, ValueFromRemainingArguments)][string[]]$items){
	$items | %{
		if(Test-Path $_ -PathType Leaf){
			[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($(rvpa $_), 'OnlyErrorDialogs', 'SendToRecycleBin')
		}
		elseif(Test-Path $_ -PathType Container){
			[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($(rvpa $_), 'OnlyErrorDialogs', 'SendToRecycleBin')
		}
		else{
			Write-Error "Path not found: $_"
		}
	}
}

function dice(){
	Read-Host 'Question' | Out-Null	
	$val = Get-Random 6 -Count 2
	Write-Host 'The dice shows ' -NoNewline
	Write-Host $val -ForegroundColor Yellow

	if($val[0]%2 -eq $val[1]%2){
		Write-Host 'Parity matches'
		Write-Host 'Yes' -ForegroundColor Green
	}
	else{
		Write-Host 'Parity mismatches'
		Write-Host 'No' -ForegroundColor Red
	}
}

function rm(){
	Write-Error 'Do not use rm. Use recycle instead.'
}

Remove-Alias ft -Force
Remove-Alias diff -Force
Remove-Alias rm -Force
Remove-Alias del -Force

sal open -Value explorer
sal ri -Value rm -Force
sal rmdir -Value rm
sal del -Value rm

if(!(Test-Path Env:SSH_CONNECTION) -or (Test-Path Env:SSH_TTY)){
	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

	if(Test-Path Env:SSH_CONNECTION){ write "Hello, remote client from $($Env:SSH_CLIENT)." }
}
