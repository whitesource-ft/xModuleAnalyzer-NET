param(
	[string]$xModulePath,
	[string]$fsaJarPath,
	[string]$c,
	[string]$d,
	[string]$productName,
	[switch]$viaDebug
)
<#
    .NAME
	xModuleAnalyzer-NET
	
	.SYNOPSIS
    Executes WhiteSource's Effective Usage Analysis scan for multi-project C# solutions.

    .DESCRIPTION
    Identifies all applicable appPath values for the solution's projects,
    Creates a dedicated xModuleAnalyzer setup file, and executes consecutive
	EUA scans for all identified projects.

    .PARAMETER xModulePath
    (Optional) Specifies the xModuleAnalyzer setup file name.
	If not provided, "./multi-module-setup_net.txt" will be used.

    .PARAMETER fsaJarPath
    (Optional) Specifies the full/relative path to the Unified Agent jar file.
	If not provided, "./wss-unified-agent.jar" will be used.
	If the agent doesn't exist in that location, it will be automatically downloaded.
	
	.PARAMETER c
	(Optional) Specifies the full/relative path to the Unified Agent's EUA config file (the file
	must exist prior to the execution).
	If not provided, "./wss-unified-agent-EUA-net.config" will be used.
	
	.PARAMETER d
	Specifies the path to the solution's root directory (the directory to be scanned).
	
	.PARAMETER productName
    (Optional) Specifies the WhiteSource Product name to be used.
	If not provided, the name of the solution's root directory will be used.
	
	.PARAMETER viaDebug
    (Optional switch) If specified, the Unified Agent will execute an EUA scan with
	debug logging enabled.

    .EXAMPLE
    PS> xModuleAnalyzer-NET -d "C:\Source\HelloWorld"

    .EXAMPLE
    PS> xModuleAnalyzer-NET -d "C:\Source\HelloWorld"

    .EXAMPLE
    PS> xModuleAnalyzer-NET -d "C:\Source\HelloWorld" -productName "Hello World 1.0"
	
	.EXAMPLE
    PS> xModuleAnalyzer-NET -xModulePath "multi-module-setup.txt" -fsaJarPath "C:\ws\wss-unified-agent.jar" -c "C:\ws\wss-unified-agent-EUA.config" -d "C:\Source\HelloWorld" -productName "Hello World 1.0" -viaDebug

    .LINK
    Source code: https://github.com/whitesource-ft/xModuleAnalyzer-NET
	
	.NOTE
	Author: Tidhar Meltzer
	#------------------------------------------------------------------------------#
	# DISCLAIMER                                                                   #
	#------------------------------------------------------------------------------#
	# This script is only a suggested integration method of a WhiteSource product. #
	# This method (including the documents, scripts and screenshots related to it) #
	# is not an official WhiteSource deliverable release.                          #
	# It is provided as-is and is not officially supported by WhiteSource, except  #
	# for best-effort assistance.                                                  #
#>

[string]$ScriptPath = $MyInvocation.MyCommand.Path;
[string]$CurFolder = Split-Path -Path $ScriptPath;
[string]$ScriptName = "xModuleAnalyzer-NET"
Push-Location -Path $CurFolder;

# If (!$xModulePath) {$xModulePath = Read-Host "xModulePath"}
If (!$xModulePath) { $xModulePath = "multi-module-setup_net.txt" }
# If (!$fsaJarPath) {$fsaJarPath = Read-Host "fsaJarPath"}
If (!$fsaJarPath) { $fsaJarPath = "wss-unified-agent.jar" }
# If (!$c) {$c = Read-Host "c"}
If (!$d) {$d = Read-Host "d"}

If ($d) {try { $d = Resolve-Path $d } catch { Write-Host "Invalid path: -d" }}

[bool]$LogTerminal = $true
[string]$TerminalLogFile = Join-Path $CurFolder "$ScriptName.log"
If ($LogTerminal) {
	If (Test-Path -Path "$TerminalLogFile" -ea 4) {Remove-Item -Path "$TerminalLogFile" -Force -ea 4}
	New-Item -ItemType File -Path "$TerminalLogFile" -Force | Out-Null
}

[int]$LineLen = 60
$StartTime = (Get-Date)

$HdrLine = $('='*$LineLen)
$ScriptName = " $ScriptName "
$HdrTitle = "{0}`n{1}`n{0}`n{2}" -f $('='*$ScriptName.Length),$ScriptName,$StartTime


Function Log ([string[]]$Text, [switch]$NoEcho, [switch]$EchoOnly) {
	If (!$NoEcho) {
		Write-Host $Text
	}
	If ($LogTerminal -and !$EchoOnly) {
		Add-Content -Path $TerminalLogFile -Value $Text
	}
}

Function Terminate([string]$Text) {
	Pop-Location -ea 4
	Write-Host "$Text" -ForegroundColor Red
	If ($LogTerminal) {
		"$Text" >> "$TerminalLogFile"
	}
	Sleep 3
	exit 1
}

Function Title([string]$Text) {
	$TitleText = "`n{0}`n{1}" -f "$Text",$('='*$Text.Length)
	Log "$TitleText"
}

Write-Host ""
Log "$HdrTitle"

If (!(Test-Path -Path "$fsaJarPath")) {
	
	Log "Downloading WhiteSource Unified Agent..."
	try {
		Invoke-WebRequest -Uri "https://unified-agent.s3.amazonaws.com/wss-unified-agent.jar" -OutFile "$fsaJarPath"
	} catch {
		Terminate "Download Failed: $_"
	}
}
If (!(Test-Path -Path "$c")) { Terminate "EUA config file not found: $c" }
If (!(Test-Path -Path "$d")) { Terminate "Directory not found: $d" } Else {
	If (!$productName) {$productName = Split-Path -Path "$d" -Leaf}
	$firstProjFile = Get-ChildItem -Path "$d" -Recurse -File | ? {$_.Extension -ieq '.csproj'} | Select -First 1 -ExpandProperty FullName
	If ($firstProjFile) {
		$RootDir = Split-Path -Path (Split-Path -Path $firstProjFile)
	}
}

$SetupFileName = (Split-Path -Path $xModulePath -Leaf)

$ProjectDirs = Get-ChildItem -Path $RootDir -Directory
$XPath = "/Project/PropertyGroup"

Title "Generating setup file"

("DependencyManagerFilePath=" + ("$RootDir" -replace '\\','/')) > "$xModulePath"

$ModuleCnt = 0
ForEach ($Dir in $ProjectDirs) {
	$ModuleCnt++
	$ScanDir = $Dir.FullName
	$csprojFile = Get-ChildItem -Path $ScanDir -File | ? {$_.Extension -ieq '.csproj'} | % {$_.FullName}
	
	If ($csprojFile) {
		[xml]$csprojXml = Get-Content -Path $csprojFile
		$AssemblyName = (($csprojXml.Project.PropertyGroup | % {$_.AssemblyName }) -as [string]).Trim()
		$OutputType = (($csprojXml.Project.PropertyGroup | % {$_.OutputType }) -as [string]).Trim()
		
		$appPathName = If ($AssemblyName) {$AssemblyName} Else {"$Dir"}
		$appPathExt = If ($OutputType -ieq "exe") {$OutputType.ToLower()} Else {"dll"}
		
		$BinDir = Join-Path $ScanDir "bin"
		$ObjDir = Join-Path $ScanDir "obj"
		If (Test-Path -Path "$BinDir") {
			$appPath = Get-ChildItem -Path "$BinDir" -Recurse -File | ? {$_.Name -ieq "$appPathName.$appPathExt"} | Select -First 1 -ExpandProperty FullName
		} ElseIf (Test-Path -Path "$ObjDir") {
			$appPath = Get-ChildItem -Path "$ObjDir" -Recurse -File | ? {$_.Name -ieq "$appPathName.$appPathExt"} | Select -First 1 -ExpandProperty FullName
		}
		
		If ($appPath) {
			Log "  Adding directory $Dir"
			
			("ProjectFolderPath$ModuleCnt=" + ("$ScanDir" -replace '\\','/')) >> "$xModulePath"
			("AppPath$ModuleCnt=" + ("$appPath" -replace '\\','/')) >> "$xModulePath"
			("defaultName$ModuleCnt=" + ("$Dir" -replace '\\','/')) >> "$xModulePath"
			("artifactId$ModuleCnt=" + ("$Dir" -replace '\\','/')) >> "$xModulePath"
			("altName$ModuleCnt=" + ("$Dir" -replace '\\','/')) >> "$xModulePath"
			("projType$ModuleCnt=nuget") >> "$xModulePath"
		} Else {
			Log "  No appPath found for directory $Dir"
			$ModuleCnt--
		}
	} Else {
		Log "  Skipping directory $Dir, no csproj file found"
		$ModuleCnt--
	}
}
Log ""

If (Test-Path -Path "$xModulePath") {
	Log "Setup file created: $xModulePath"
	
	$xModuleContent = Get-Content -Path "$xModulePath"
	[string[]]$ScanDirs = $xModuleContent | ? {$_.StartsWith("ProjectFolderPath")} | % {$($_ -split '=')[1]}
	[string[]]$AppPaths = $xModuleContent | ? { $_.StartsWith("AppPath") } | % { $($_ -split '=')[1]}
	[string[]]$ProjectNames = $xModuleContent | ? { $_.StartsWith("defaultName") } | % { $($_ -split '=')[1]}
} Else {
	Terminate "Setup file not found: $xModulePath"
}
If ($AppPaths.Count -gt 0) {
	If ($ScanDirs.Count -ne $AppPaths.Count -or $AppPaths.Count -ne $ProjectNames.Count) {
		Terminate "Failed to parse setup file"
	}
	
	Title "Starting multi-module scan"
	
	$FailedModuleCnt = 0
	$ModuleCnt = $ScanDirs.Count
	Push-Location -Path (Split-Path $fsaJarPath);
	
	For ($i = 0; $i -lt $ModuleCnt; $i++) {
		Log ("{0} Scanning Module {1}/{2}: {3}" -f (Get-Date -f "[HH:mm:ss]"),($i+1),$ModuleCnt,$ProjectNames[$i])
		
		# UA Command
		$UACmd = 'java -jar "{0}" -c "{1}" -appPath "{2}" -d "{3}" -product "{4}" -project "{5}" -viaDebug {6}' `
					-f "$fsaJarPath","$c",$AppPaths[$i],$ScanDirs[$i],"$productName",$ProjectNames[$i], "$viaDebug".ToLower();
		
		Log "`tUA Command: $UACmd`n" -NoEcho
		$CmdOutput = (cmd /c "$UACmd" 2>&1); $eCode = $LASTEXITCODE;
		Log -Text $CmdOutput -NoEcho
		
		If ($eCode -eq 0) {
			Log ("{0} Success ($eCode)" -f (Get-Date -f "[HH:mm:ss]"))
		} Else {
			$FailedModuleCnt++
			Log ("{0} Failed ($eCode)" -f (Get-Date -f "[HH:mm:ss]"))
		}
		Log ""
	}
	
	If ($FailedModuleCnt -gt 0) {
		$ExitCode = -1
		Log "Scan complete with errors"
		$FailedText = "{0}/{1} Modules Failed`n" -f $FailedModuleCnt,$ModuleCnt
	} Else {
		Log "Scan complete"
	}
	Pop-Location
	$Duration = New-TimeSpan -Start $StartTime -End (Get-Date)
	Log ("`nDuration: {0:hh}:{0:mm}:{0:ss}" -f $Duration)
} Else {
	Terminate "`nNo artifacts found that can be scanned for EUA`n"
}
Pop-Location -ea 4
exit [int]$ExitCode