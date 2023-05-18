function proxy($set = 1) {
	switch ($set) {
		0 {
			Remove-Item Env:http_proxy
			Remove-Item Env:https_proxy
		}
		1 {
			$Env:http_proxy = 'http://localhost:7890'
			$Env:https_proxy = 'http://localhost:7890'
		}
		2 {
			$Env:http_proxy = 'http://localhost:8889'
			$Env:https_proxy = 'http://localhost:8889'
		}
	}
}

function showPath($pattern) {
	$tmp = $Env:path -split ';' -match $pattern
	$tmp | Measure-Object -Line
	Get-Variable tmp -ValueOnly
}

function lt([switch]$Descending) {
	if ($Descending.IsPresent) { Get-ChildItem | Sort-Object LastWriteTime -Descending }
	else { Get-ChildItem | Sort-Object LastWriteTime }
}

function du($dir = '.') {
	Get-ChildItem $dir -Recurse -Force | Measure-Object -Property Length -Sum
}

function pipUpdate {
	python -m pip install -U pip
	(pipdeptree --warn silence) -match '^\w+' | ForEach-Object { $_.split('==')[0] } | ForEach-Object { pip install -U $_ }
	pip cache purge
}

function showSSHlogs($count = 10) {
	Get-WinEvent -Path $Env:SystemRoot\System32\Winevt\Logs\OpenSSH%4Operational.evtx -MaxEvents $count
}

function getHistory($count = 50) {
	Get-Content (Get-PSReadlineOption).HistorySavePath -Tail $count
}

function su($dir = '.') {
	Start-Process wt "-d $dir" -Verb RunAs
}

function gitShallone([Parameter(Mandatory)]$repo) {
	git clone $repo --depth 1
}

function addRegistryLocations() {
	if (!(Test-Path HKCR:)) { New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR -Scope Global }
	if (!(Test-Path HKCU:)) { New-PSDrive -PSProvider Registry -Root HKEY_CURRENT_USER -Name HKCU -Scope Global }
	if (!(Test-Path HKLM:)) { New-PSDrive -PSProvider Registry -Root HKEY_LOCAL_MACHINE -Name HKLM -Scope Global }
	if (!(Test-Path HKU:)) { New-PSDrive -PSProvider Registry -Root HKEY_USERS -Name HKU -Scope Global }
	if (!(Test-Path HKCC:)) { New-PSDrive -PSProvider Registry -Root HKEY_CURRENT_CONFIG -Name HKCC -Scope Global }
}

function newRegistryItemForOpen([Parameter(Mandatory)][string]$Ext,
	[Parameter(Mandatory)][string]$Program,	[Parameter(Mandatory)][string]$IconPath) {
	New-Item ".$($Ext)_auto_file" && \
	New-Item ".$($Ext)_auto_file\DefaultIcon" && \
	New-Item ".$($Ext)_auto_file\shell" && \
	New-Item ".$($Ext)_auto_file\shell\open" && \
	New-Item ".$($Ext)_auto_file\shell\open\command" && \
	Set-ItemProperty ".$($Ext)_auto_file\DefaultIcon" -Name '(default)' -Value $IconPath && \
	Set-ItemProperty ".$($Ext)_auto_file\shell\open" -Name '(default)' -Value """$Program""" && \
	Set-ItemProperty ".$($Ext)_auto_file\shell\open\command" -Name '(default)' -Value """$Program"" ""%1""" && \
}

function dYTaudio([Parameter(Mandatory)]$URL) {
	yt-dlp -f ba -x --audio-format mp3 $URL
}

function dYTvideo([Parameter(Mandatory)]$URL) {
	yt-dlp --merge-output-format mp4 $URL
}

function ft([Parameter(Mandatory, ValueFromPipeline)]$table) {
	$table | Format-Table -Wrap
}

function find([Parameter(Mandatory)]$path, [Parameter(Mandatory)]$name) {
	Get-ChildItem $path -Recurse -Force -Include $name
}

function ln([Parameter(Mandatory)]$src, [Parameter(Mandatory)]$linkpath) {
	New-Item -ItemType SymbolicLink -Target $src $linkpath
}

function rcc([Parameter(Mandatory, ValueFromRemainingArguments)][string[]]$items) {
	$items | ForEach-Object {
		if (Test-Path $_ -PathType Leaf) {
			[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($(Resolve-Path $_), 'OnlyErrorDialogs', 'SendToRecycleBin')
		}
		elseif (Test-Path $_ -PathType Container) {
			[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($(Resolve-Path $_), 'OnlyErrorDialogs', 'SendToRecycleBin')
		}
		else {
			Write-Error "Path not found: $_"
		}
	}
}

function dice() {
	Read-Host 'Question' | Out-Null
	$val = Get-Random 6 -Count 2
	Write-Host 'The dice shows ' -NoNewline
	Write-Host $val -ForegroundColor Yellow

	if ($val[0] % 2 -eq $val[1] % 2) {
		Write-Host 'Parity matches'
		Write-Host 'Yes' -ForegroundColor Green
	}
	else {
		Write-Host 'Parity mismatches'
		Write-Host 'No' -ForegroundColor Red
	}
}

function rm() {
	Write-Error 'Do not use rm. Use rcc instead.'
}

function op($dir = '.') {
	explorer $dir
}

Remove-Alias ft -Force
Remove-Alias diff -Force
Remove-Alias rm -Force

Set-Alias open -Value explorer
Set-Alias ri -Value rm -Force
Set-Alias del -Value rm -Option AllScope
Set-Alias rmdir -Value rm
Set-Alias mk -Value make

if (!(Test-Path Env:SSH_CONNECTION) -or (Test-Path Env:SSH_TTY)) {
	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

	if (Test-Path Env:SSH_CONNECTION) { Write-Host "Hello, remote client from $($Env:SSH_CLIENT)." }
}
