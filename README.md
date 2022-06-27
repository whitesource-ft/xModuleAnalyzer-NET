![Logo](https://resources.mend.io/mend-sig/logo/mend-dark-logo-horizontal.png)

[![License](https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub release](https://img.shields.io/github/v/release/whitesource-ft/xModuleAnalyzer-NET.svg?include_prereleases)](https://github.com/whitesource-ft/xModuleAnalyzer-NET/releases/latest)  
# Mend xModuleAnalyzer-NET
**xModuleAnalyzer-NET** is a tool that executes Mend's [Prioritize (EUA)](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1526530201/Scanning+Projects+with+WhiteSource+Prioritize) scans for multi-project C# solutions.  
It imitates the execution method of Mend's [xModuleAnalyzer](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1525416207/Scanning+with+Multi-Module+Analysis), except it performs the [analyzeMultiModule setup](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1525416207/Scanning+with+Multi-Module+Analysis#Setup-File-Structure-%26-Contents) step automatically, so both the setup and the scan are combined into a single execution.  

The tool identifies the applicable [appPath](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1525416207/Scanning+with+Multi-Module+Analysis#Setup-File-Structure-%26-Contents) values for each of the solution's projects, creates a dedicated [xModuleAnalyzer setup file](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1525416207/Scanning+with+Multi-Module+Analysis#Setup-File-Structure-%26-Contents) and executes consecutive EUA scans for all identified projects.  

### Important Notes
- By default, the Mend Product name would be the name of the solution's (`*.sln`) root directory, unless you override it using the `productName` parameter.  
- Project names cannot be specified; the tool will automatically create one Mend Project for each of the solution's projects (`*.csproj`) based on their assembly names.  
- **xModuleAnalyzer-NET** does not support multi-threading currently, so as opposed to [**xModuleAnalyzer**](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1525416207/Scanning+with+Multi-Module+Analysis), which can scan up to 8 modules in parallel, **xModuleAnalyzer-NET** executes the scans consecutively, which increases overall scan times.  

## Supported Operating Systems
- **Windows (PowerShell):**	10, 2012, 2016

## Supported Project Types
C# solutions with one or more projects that include open-source NuGet packages.  
NuGet packages may be referenced either in a `packages.config` file or within each project's manifest file (`*.csproj`).  

## Prerequisites
See [Mend Prioritize (EUA) Prerequisites](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1526530201/Scanning+Projects+with+WhiteSource+Prioritize#Prerequisites)

## Installation
1. Download the latest [xModuleAnalyzer-NET](https://github.com/whitesource-ft/xModuleAnalyzer-NET/releases/latest/download/xModuleAnalyzer-NET.zip) package to your computer and extract it.
2. Modify the provided **wss-unified-agent-EUA-net.config** file as needed, or alternatively, use your own EUA (Mend Prioritize) configuration file.  
   The configuration file must be placed in the same directory as **xModuleAnalyzer-NET.ps1**.  

## Execution
  - **PowerShell:**  
  Navigate to the directory where **xModuleAnalyzer-NET.ps1** is located and enter the execution command:  
  `PS C:\Mend> xModuleAnalyzer-NET.ps1 [-key "value"[]]]`  

### Command-Line Parameters
All parameters are consistent with the Mend [Unified Agent](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1544880156/Unified+Agent+Configuration+Parameters#Configuration-File-Parameters) and [xModuleAnalyzer](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1525416207/Scanning+with+Multi-Module+Analysis#Command-Line-Parameters) command-line parameters.  

| Parameter | Type | Required | Description |
| :--- | :---: | :---: | :--- |
| **&#x2011;xModulePath** | string | No | Specifies the xModuleAnalyzer setup file name. If not provided, `"./multi-module-setup_net.txt"` will be used. |
| **&#x2011;fsaJarPath** | string | No | Specifies the full/relative path to the Unified Agent jar file. If not provided, `"./wss-unified-agent.jar"` will be used. If the agent doesn't exist in that location, it will be automatically downloaded. |
| **&#x2011;c** | string | No | Specifies the full/relative path to the Unified Agent's EUA config file (the file must exist prior to the execution). If not provided, `"./wss-unified-agent-EUA-net.config"` will be used. |
| **&#x2011;d** | string | Yes | Specifies the path to the solution's root directory (the directory to be scanned). |
| **&#x2011;productName** | string | No | Specifies the Mend Product name to be used. If not provided, the name of the solution's root directory will be used. |
| **&#x2011;viaDebug** | switch | No | If specified, the Unified Agent will execute an EUA scan with debug logging enabled. Note that this is a PowerShell switch, not a boolean. To use it, just add `-viaDebug` (and not `-vaDebug true`). |

### Execution Examples
Scanning the multi-project solution **HelloWorld**:  
`PS C:\Mend> xModuleAnalyzer-NET.ps1 -d "C:\Source\HelloWorld"`  
  
Scanning the multi-project solution **HelloWorld**, specifying a product name:  
`PS C:\Mend> xModuleAnalyzer-NET.ps1 -d "C:\Source\HelloWorld" -productName "Hello World 1.0"`  
  
Sample command using all parameters:  
`PS C:\Mend> xModuleAnalyzer-NET.ps1 -xModulePath "multi-module-setup.txt" -fsaJarPath "C:\ws\wss-unified-agent.jar" -c "C:\ws\wss-unified-agent-EUA.config" -d "C:\Source\HelloWorld" -productName "Hello World 1.0" -viaDebug`  
