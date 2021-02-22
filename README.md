### add-New-Agent.ps1

This script is to download and configure self-hosted agent in an Azure DevOps organization and install all required packages by using choco

#### Example
`.\add-New-Agent.ps1 -organizationName SUNKARA-VINOD -PAT ********** -agentPool On-premises -agentName VINOD-TEST`

### Install packages
To install the packages, add list of packages to `$packages` parameter before executing the script

#### Example
`$Packages = 'googlechrome' , 'git' , 'notepadplusplus' , 'googlechrome'`