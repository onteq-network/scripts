###########################################
#										  #	
# Zabbix Agent Install Script			  #
#										  #
###########################################
# Install Zabbix agent on Windows
# Created by Team - Onsight Solutons
# Last updated 
# Installs Zabbix Agent 5.0


$version500ssl = "https://codeload.github.com/onteq-network/monitoring-agent/zip/master"


# https://drive.google.com/open?id=1IbWJjLpJ0-X3mIjcVyvf0E3zcM1zX3vc

#Gets the server host name
$serverHostname =  Invoke-Command -ScriptBlock {hostname}

# Asks the user for the IP address of their Zabbix server
$ServerIP = Read-Host -Prompt 'What is your Zabbix server/proxy IP/DNS?'

#Asks the user for the Port Number of their Zabbix server
$ServerPort = Read-Host -Prompt 'What is your Zabbix Listening Port Number(10050,10052-10060)?'

# Asks the user for the Port Number of their PSKID
$PSKID = Read-Host -Prompt 'What is your PSK ID (Ex: id-hostname)?'

# # Asks the user for the Port Number of their PSKSecret
$PSKSecret = Read-Host -Prompt 'What is your PSK SECERET?'

$Path= 'c:\Agent\zabbix'

# Creates Zabbix DIR
mkdir c:\Agent\zabbix\


# Downloads the version you want. Links are up. This script currently as standard downloads version 5.0.0 with SSL option
Invoke-WebRequest "$version500ssl" -outfile $Path\zabbix.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# Unzipping file to c:\zabbix
Unzip "$path\zabbix.zip" "$path"
Unzip "$path\monitoring-agent-master\agent-onsight.zip" "$path"

#delete folder and file
Remove-Item 'C:\Agent\zabbix\monitoring-agent-master' -Recurse
Remove-Item 'C:\Agent\zabbix\zabbix.zip' -Recurse

# Sorts files in c:\zabbix
Move-Item $Path\bin\zabbix_agentd.exe -Destination $Path

# Sorts files in c:\zabbix
Move-Item $Path\conf\zabbix_agentd.conf -Destination $Path

# Replaces 127.0.0.1 with your Zabbix server IP in the config file
(Get-Content -Path $Path\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '127.0.0.1', "$ServerIP"} | Set-Content -Path $Path\zabbix_agentd.conf

# Replaces hostname in the config file
(Get-Content -Path $Path\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'Windows host', "$ServerHostname"} | Set-Content -Path $Path\zabbix_agentd.conf

# Replaces PortNumber in the config file
(Get-Content -Path $Path\zabbix_agentd.conf) | ForEach-Object {$_ -Replace '10050', "$ServerPort"} | Set-Content -Path $Path\zabbix_agentd.conf

# Replaces PSKID in the config file
(Get-Content -Path $Path\zabbix_agentd.conf) | ForEach-Object {$_ -Replace 'pskid_onteq', "$PSKID"} | Set-Content -Path $Path\zabbix_agentd.conf

#create file 
New-Item $Path\. -Name "psk.key" -ItemType "file" -Value "$PSKSecret"
New-Item c:\Agent\. -Name "Readme.txt" -ItemType "file" -Value "This Folder contains the monitoring agent configurartion files created by Onsight Solutions"

# Attempts to install the agent with the config in c:\zabbix
c:\Agent\zabbix\zabbix_agentd.exe --config c:\Agent\zabbix\zabbix_agentd.conf --install

# Attempts to start the agent
c:\Agent\zabbix\zabbix_agentd.exe --start

# Creates a firewall rule for the Zabbix server
New-NetFirewallRule -DisplayName "Allow Zabbix communication" -Direction Inbound -Program "c:\Agent\zabbix\zabbix_agentd.exe" -RemoteAddress LocalSubnet -Action Allow
