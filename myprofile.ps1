# set command line proxy
function proxy($set = 1) {
	switch ($set) {
		0 {
			Remove-Item Env:http_proxy
			Remove-Item Env:https_proxy
		}
		1 {
			$env:http_proxy = 'http://localhost:7890'
			$env:https_proxy = 'http://localhost:7890'
		}
		2 {
			$env:http_proxy = 'http://localhost:8890'
			$env:https_proxy = 'http://localhost:8890'
		}
	}
}

# ask for confirmation
function askConfirm() {
	$answer = Read-Host 'Proceed? [y/N]'
	if ($answer -eq 'y' -or $answer -eq 'Y') { return $true }
	else { return $false }
}

# print system path that matches the pattern
function showPath($pattern) {
	$path = $env:Path -split ';' -match $pattern
	$path | Measure-Object -Line
	Get-Variable path -ValueOnly
}

function showCustomPath() {
	$path = $env:Path -split ';' -notmatch 'windows|system32|nvidia'
	Get-Variable path -ValueOnly
}

# add system path
function addPath($newpath) {
	$env:Path += ";$newpath"
}

# list items sorted by last-write-time
function lt([switch]$Descending) {
	if ($Descending.IsPresent) { Get-ChildItem | Sort-Object LastWriteTime -Descending }
	else { Get-ChildItem | Sort-Object LastWriteTime }
}

# disk usage
function du($dir = '.') {
	$size = (Get-ChildItem $dir -Recurse -Force | Measure-Object -Property Length -Sum).Sum
	Write-Host "Size of ${dir}: " -NoNewline
	$size_kb = [math]::Round($size / 1kb, 2)
	$size_mb = [math]::Round($size / 1mb, 2)
	$size_gb = [math]::Round($size / 1gb, 2)
	if ($size_kb -lt 1) { Write-Host "${size} bytes" }
	elseif ($size_mb -lt 1) { Write-Host "${size_kb} KB" }
	elseif ($size_gb -lt 1) { Write-Host "${size_mb} MB" }
	else { Write-Host "${size_gb} GB" }
}

# update pip packages
function pipUpdate {
	python -m pip install -U pip
	(pipdeptree --warn silence) -match '^\w+' | ForEach-Object { $_.split('==')[0] } | ForEach-Object { pip install -U $_ }
	pip cache purge
}

# print SSHD logs
function showSSHlogs($count = 10) {
	Get-WinEvent -Path $env:SystemRoot\System32\Winevt\Logs\OpenSSH%4Operational.evtx -MaxEvents $count
}

# get powershell history
function getHistory($count = 50, [switch]$all) {
	if ($all.IsPresent) { Get-Content (Get-PSReadlineOption).HistorySavePath }
	else {	Get-Content (Get-PSReadlineOption).HistorySavePath -Tail $count }
}

# start another wt instance with admin privilege
function su($dir = '.') {
	Start-Process wt "-d $dir" -Verb RunAs
}

# git clone with depth 1
function gitShallone([Parameter(Mandatory)]$repo, [switch]$NoSingleBranch) {
	if ($NoSingleBranch.IsPresent) { git clone $repo --depth 1 --no-single-branch }
	else { git clone $repo --depth 1 }
}

# git pull with depth 1
function gitPullow() {
	git fetch --depth 1
	git reset --hard origin/$(git branch --show-current)
}

# add entry for registry
function addRegistryLocations() {
	if (!(Test-Path HKCR:)) { New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR -Scope Global }
	if (!(Test-Path HKCU:)) { New-PSDrive -PSProvider Registry -Root HKEY_CURRENT_USER -Name HKCU -Scope Global }
	if (!(Test-Path HKLM:)) { New-PSDrive -PSProvider Registry -Root HKEY_LOCAL_MACHINE -Name HKLM -Scope Global }
	if (!(Test-Path HKU:)) { New-PSDrive -PSProvider Registry -Root HKEY_USERS -Name HKU -Scope Global }
	if (!(Test-Path HKCC:)) { New-PSDrive -PSProvider Registry -Root HKEY_CURRENT_CONFIG -Name HKCC -Scope Global }
}

# set a registry entry for the icon and open command of a specific file type
function newRegistryItemForOpen([Parameter(Mandatory)][string]$Ext,
	[Parameter(Mandatory)][string]$Program,	[Parameter(Mandatory)][string]$IconPath) {
	Write-Host "Setting registry for $Ext files with icon $IconPath and opening program $Program"
	if ((askConfirm) -eq $false) { return }
	New-Item ".$($Ext)_auto_file" && \
	New-Item ".$($Ext)_auto_file\DefaultIcon" && \
	New-Item ".$($Ext)_auto_file\shell" && \
	New-Item ".$($Ext)_auto_file\shell\open" && \
	New-Item ".$($Ext)_auto_file\shell\open\command" && \
	Set-ItemProperty ".$($Ext)_auto_file\DefaultIcon" -Name '(default)' -Value $IconPath && \
	Set-ItemProperty ".$($Ext)_auto_file\shell\open" -Name '(default)' -Value """$Program""" && \
	Set-ItemProperty ".$($Ext)_auto_file\shell\open\command" -Name '(default)' -Value """$Program"" ""%1""" && \
}

# download youtube audio
function dYTaudio([Parameter(Mandatory)]$URL, [Parameter(Mandatory)]$cookiefile) {
	yt-dlp --cookies $cookiefile -f ba -x --audio-format mp3 $URL
}

# download youtube video
function dYTvideo([Parameter(Mandatory)]$URL, [Parameter(Mandatory)]$cookiefile) {
	yt-dlp --cookies $cookiefile -S proto --abort-on-unavailable-fragments --merge-output-format mp4 $URL
}

# format table with wrap
function ft([Parameter(Mandatory, ValueFromPipeline)]$table) {
	$table | Format-Table -Wrap
}

# find files with name
function find([Parameter(Mandatory)]$path, [Parameter(Mandatory)]$name) {
	Get-ChildItem $path -Recurse -Force -Include $name
}

# set symbolic link
function ln([Parameter(Mandatory)]$src, [Parameter(Mandatory)]$linkpath) {
	New-Item -ItemType SymbolicLink -Target $src $linkpath
}

# send file to recycle bin
function trash([Parameter(Mandatory, ValueFromRemainingArguments)][string[]]$items) {
	$items | ForEach-Object {
		if (Test-Path $_ -PathType Leaf) {
			[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile((Resolve-Path $_), 'OnlyErrorDialogs', 'SendToRecycleBin')
		}
		elseif (Test-Path $_ -PathType Container) {
			[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory((Resolve-Path $_), 'OnlyErrorDialogs', 'SendToRecycleBin')
		}
		else {
			Write-Error "Path not found: $_"
		}
	}
}

# get full control to a path
function getFullControl([Parameter(Mandatory)]$path) {
	Write-Host "Setting full control for $path"
	if ((askConfirm) -eq $false) { return }
	$acl = Get-Acl $path
	$identity = "$env:COMPUTERNAME\$env:USERNAME"
	$fileSystemRights = 'FullControl'
	$type = 'Allow'
	$ar = New-Object System.Security.AccessControl.FileSystemAccessRule $identity, $fileSystemRights, $type
	$acl.SetAccessRule($ar)
	Set-Acl $path $acl
}

# roll a dice for a question
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

# block remove-item alias
function rm() {
	Write-Error 'Do not use rm. Use rcc instead.'
}

function npm() {
	Write-Error 'Do not use npm. Use pnpm instead.'
}

# alias for open
function op($dir = '.') {
	explorer $dir
}

# change directory to the parent of a file
function cf([Parameter(Mandatory)]$file) {
	Set-Location (Split-Path $file)
}

# implement wget with curl
function wget([Parameter(Mandatory)]$url) {
	Invoke-WebRequest $url -OutFile (Split-Path $url -Leaf)
}

# Output the content of all files in a directory
function catAll($dir = '.') {
	Get-ChildItem $dir -File | `
		ForEach-Object {
		Write-Host -ForegroundColor Green $_
		Write-Host -ForegroundColor Yellow ----------
		Get-Content $_
		Write-Host -ForegroundColor Yellow ----------`n
	}
}

# Get the uptime of the system
function uptime() {
	$bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
	$upTime = ((Get-Date) - $bootTime).ToString('d\d\.h\:mm\:ss')
	Write-Host "Boot at $bootTime, up for $upTime"
}

# reset all branches to discard all commit historys
function gitResetRepoCommit() {
	Write-Host -NoNewline 'You are about to discard all commit historys. '
	if ((askConfirm) -eq $false) { return }
	git branch -l | ForEach-Object {
		git checkout $_
		git reset --hard (git commit-tree HEAD^`{tree`} -m 'Init commit')
	}
}

# check out all remote branches
function gitCheckAllBranch() {
	git branch -r | Where-Object { $_ -notcontains 'HEAD' } | ForEach-Object {
		git checkout (Split-Path $_ -Leaf)
	}
}

# randomly choose from a list
function randChoose([Parameter(Mandatory, ValueFromRemainingArguments)]$items) {
	$items | Get-Random
}

# randomly shuffle a list
function shuffle([Parameter(Mandatory, ValueFromRemainingArguments)]$items) {
	$items | Get-Random -Shuffle
}

# touch a file
function touch([Parameter(Mandatory)]$file) {
	if (Test-Path $file) { (Get-Item $file).LastWriteTime = Get-Date }
	else { New-Item $file -ItemType File }
}

# Download all files in http server of a folder
function downloadFolder([Parameter(Mandatory)]$url) {
	if ($url[-1] -ne '/') { $url += '/' }
	$content = (Invoke-WebRequest $url).Content
	$files = (Select-String -InputObject $content 'href="([^"]+)"' -AllMatches).Matches.Groups
	$files = $files | ForEach-Object { $_.ToString().TrimStart('/') } | Where-Object {
		$_.Length -gt 0 -and $_ -notlike 'href*' -and $_ -notlike '~*' -and
		$_ -notlike '.*' -and $_ -notlike '`?*' -and $_ -notlike '*/'
	}
	$count = $files.Length
	Write-Host "Totally $count files found."
	$i = 1
	$files | ForEach-Object {
		Write-Host "Downloading $i of ${count}: $_"
		wget($url + $_)
		$i++
	}
}

# Get the hash of a string
function getHash([Parameter(Mandatory)]$str,
	[ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]$Algorithm = 'MD5') {
	switch ($Algorithm) {
		'MD5' { $hasher = [System.Security.Cryptography.MD5]::Create() }
		'SHA1' { $hasher = [System.Security.Cryptography.SHA1]::Create() }
		'SHA256' { $hasher = [System.Security.Cryptography.SHA256]::Create() }
		'SHA384' { $hasher = [System.Security.Cryptography.SHA384]::Create() }
		'SHA512' { $hasher = [System.Security.Cryptography.SHA512]::Create() }
	}
	$hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($str))
	Write-Host ([BitConverter]::ToString($hash) -replace '-', '')
}

Remove-Alias ft -Force
Remove-Alias diff -Force
Remove-Alias rm -Force

Set-Alias open -Value explorer
Set-Alias ri -Value rm -Force
Set-Alias del -Value rm -Option AllScope
Set-Alias rmdir -Value rm
Set-Alias mk -Value make
Set-Alias which -Value Get-Command

if (!(Test-Path Env:SSH_CONNECTION) -or (Test-Path Env:SSH_TTY)) {
	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineKeyHandler Tab MenuComplete
	Set-PSReadLineKeyHandler Ctrl+RightArrow ForwardWord
	Set-PSReadLineKeyHandler UpArrow HistorySearchBackward
	Set-PSReadLineKeyHandler DownArrow HistorySearchForward
	Set-PSReadLineKeyHandler Ctrl+d DeleteCharOrExit

	if (Test-Path Env:SSH_CONNECTION) { Write-Host "Hello, remote client from $env:SSH_CLIENT." }
}