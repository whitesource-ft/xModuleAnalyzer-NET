![Logo](https://whitesource-resources.s3.amazonaws.com/ws-sig-images/Whitesource_Logo_178x44.png)  

[![License](https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub release](https://img.shields.io/github/release/whitesource-ft/wss-template.svg)](https://github.com/whitesource-ft/wss-template/releases/latest)  
# WhiteSource xModuleAnalyzer-NET
**xModuleAnalyzer-NET** is a tool that executes WhiteSource's [Effective Usage Analysis](https://whitesource.atlassian.net/wiki/spaces/WD/pages/572751999/Introduction+to+WhiteSource+Prioritize#IntroductiontoWhiteSourcePrioritize-WhatisEffectiveUsageAnalysis?) scans for multi-project C# solutions.  
It imitates the execution method of WhiteSource's [xModuleAnalyzer](https://whitesource.atlassian.net/wiki/spaces/WD/pages/651919363/EUA+Support+for+Multi-Module+Analysis), except it performs the [analyzeMultiModule setup](https://whitesource.atlassian.net/wiki/spaces/WD/pages/651919363/EUA+Support+for+Multi-Module+Analysis#EUA:SupportforMulti-ModuleAnalysis-Step1:RuntheUnifiedAgentwiththe'-analyzeMultiModule'Parameter) step automatically, so both the setup and the scan are combined into a single execution.  

The tool identifies the applicable [appPath](https://whitesource.atlassian.net/wiki/spaces/WD/pages/651919363/EUA+Support+for+Multi-Module+Analysis#EUA:SupportforMulti-ModuleAnalysis-SetupFileStructure&Contents) values for each of the solution's projects, creates a dedicated [xModuleAnalyzer setup file](https://whitesource.atlassian.net/wiki/spaces/WD/pages/651919363/EUA+Support+for+Multi-Module+Analysis#EUA:SupportforMulti-ModuleAnalysis-SetupFileStructure&Contents) and executes consecutive EUA scans for all identified projects.  

### Important Notes
- By default, the WhiteSource Product name would be the name of the solution's (`*.sln`) root directory, unless you override it using the `productName` parameter.  
- Project names cannot be specified; the tool will automatically create one WhiteSource Project for each of the solution's projects (`*.csproj`) based on their assembly names.  
- **xModuleAnalyzer-NET** does not support multi-threading currently, so as opposed to [**xModuleAnalyzer**](https://whitesource.atlassian.net/wiki/spaces/WD/pages/651919363/EUA+Support+for+Multi-Module+Analysis), which can scan up to 8 modules in parallel, **xModuleAnalyzer-NET** executes the scans consecutively, which increases overall scan times.  

## Supported Operating Systems
- **Windows (PowerShell):**	10, 2012, 2016

## Supported Project Types
C# solutions with one or more projects that include open-source NuGet packages.  
NuGet packages may be referenced either in a `packages.config` file or wihin each project's manifest file (`*.csproj`).  

## Prerequisites
See [WhiteSource Prioritize (EUA) Prerequisites](https://whitesource.atlassian.net/wiki/spaces/WD/pages/572850338/EUA+Setting+Up+a+Project+for+Effective+Usage+Analysis)

## Installation
1. Download **xModuleAnalyzer-NET.ps1** to your computer.
2. Download **wss-unified-agent-EUA-net.config** and modify the configuration as needed, or alternatively, provide your own EUA (WhiteSource Prioritize) configuration file.  
   The configuration file must be placed in the same directory as **xModuleAnalyzer-NET.ps1**.  

## Execution
  - **PowerShell:**  
  Navigate to the directory where **xModuleAnalyzer-NET.ps1** is located and enter the execution command:  
  `PS C:\WhiteSource> xModuleAnalyzer-NET.ps1 [-key "value"[]]]`  

### Command-Line Parameters
All parameters are consistent with the WhiteSource [Unified Agent](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1544880156/Unified+Agent+Configuration+Parameters#Configuration-File-Parameters) and [xModuleAnalyzer](https://whitesource.atlassian.net/wiki/spaces/WD/pages/651919363/EUA+Support+for+Multi-Module+Analysis#EUA:SupportforMulti-ModuleAnalysis-CommandLineParameters) command-line parameters.  

| Parameter | Type | Required | Description |
| :--- | :---: | :---: | :--- |
| **&#x2011;xModulePath** | string | No | Specifies the xModuleAnalyzer setup file name. If not provided, "`./multi-module-setup_net.txt`" will be used. |
| <nobr>**-fsaJarPath**</nobr> | string | No | Specifies the full/relative path to the Unified Agent jar file. If not provided, "`./wss-unified-agent.jar`" will be used. If the agent doesn't exist in that location, it will be automatically downloaded. |
| <nobr>**-c**</nobr> | string | No | Specifies the full/relative path to the Unified Agent's EUA config file (the file must exist prior to the execution). If not provided, "`./wss-unified-agent-EUA-net.config`" will be used. |
| <nobr>**-d**</nobr> | string | Yes | Specifies the path to the solution's root directory (the directory to be scanned). |
| <nobr>**-productName**</nobr> | string | No | Specifies the WhiteSource Product name to be used. If not provided, the name of the solution's root directory will be used. |
| <nobr>**-viaDebug**</nobr> | switch | No | If specified, the Unified Agent will execute an EUA scan with debug logging enabled. Note that this is a PowerShell switch, not a boolean. To use it, just add `-viaDebug` (and not `-vaDebug true`). |

### Execution Examples
Scanning the multi-project solution **HelloWorld**:  
`PS C:\WhiteSource> xModuleAnalyzer-NET.ps1 -d "C:\Source\HelloWorld"`  
  
Scanning the multi-project solution **HelloWorld**, specifying a product name:  
`PS C:\WhiteSource> xModuleAnalyzer-NET.ps1 -d "C:\Source\HelloWorld" -productName "Hello World 1.0"`  
  
Sample command using all parameters:  
`PS C:\WhiteSource> xModuleAnalyzer-NET.ps1 -xModulePath "multi-module-setup.txt" -fsaJarPath "C:\ws\wss-unified-agent.jar" -c "C:\ws\wss-unified-agent-EUA.config" -d "C:\Source\HelloWorld" -productName "Hello World 1.0" -viaDebug`  
  
