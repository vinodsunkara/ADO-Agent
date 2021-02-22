<#
.SYNOPSIS
    Install Azure DevOps self-hosted agent throgh script
    Install choco
    Install all required packages
.DESCRIPTION
    Script to download and configure self-hosted agent in Azure DevOps organization and install required packages by using choco
.EXAMPLE
    .\add-New-Agent.ps1 -organizationName SUNKARA-VINOD -PAT ********** -agentPool On-premises -agentName VINOD-TEST
.NOTES
    Requires -RunAsAdministrator
#>
param(
	[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] [string]$organizationName,
	[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] [string]$PAT,
	[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] [string]$agentPool,
	[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] [string]$agentName
)

# Packages needs to install
$packages = 'git'


Start-Transcript
Write-Host "start"

# Test if an old installation exists, if so, delete the folder
if (Test-Path "c:\agent")
{
	Remove-Item -Path "c:\agent" -Force -Recurse -Confirm:$false
}

# Create a new folder
New-Item -ItemType Directory -Force -Path "c:\agent"
Set-Location "c:\agent"

$env:VSTS_AGENT_HTTPTRACE = $true

# Github requires tls 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get the latest build agent version
$wr = Invoke-WebRequest https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest -UseBasicParsing
$tag = ($wr | ConvertFrom-Json)[0].tag_name
$tag = $tag.Substring(1)

Write-Host "$tag is the latest version"
# Build the url
$download = "https://vstsagentpackage.azureedge.net/agent/$tag/vsts-agent-win-x64-$tag.zip"

# Download the agent
Invoke-WebRequest $download -Out agent.zip

# Expand the zip
Expand-Archive -Path agent.zip -DestinationPath $PWD

# Run the config script of the build agent
.\config.cmd --unattended --url "https://dev.azure.com/$organizationName" --auth pat --token "$PAT" --pool "$agentPool" --agent "$agentName" --acceptTeeEula --runAsService

# Delete .zip file
Remove-Item .\agent.zip

# Install chocolatey if not installed and Install all required softwares by using choco

if (Test-Path -Path "$env:ProgramData\Chocolatey") {
	# Install Packages
	foreach ($PackageName in $Packages)
	{
		choco install $PackageName -y
	}
}
else {
	# Install Choco
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

	# Install Packages
	foreach ($PackageName in $Packages)
	{
		choco install $PackageName -y
	}
}

# Exit
Stop-Transcript
exit 0
