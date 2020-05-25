###########################################
#										  #	
# Zabbix Agent Uninstall Script			  #
#										  #
###########################################
# Uninstall Zabbix agent on Windows
# Created by Team - Onsight Solutons
# Last updated 
# Installs Zabbix Agent 5.0



# Attempts to stop the Zabbix service on the Windows machine
c:\Agent\zabbix\zabbix_agentd.exe --stop

Write-Host zabbix_agentd has been stopped

# Attempts to uninstall the Zabbix agent on the Windows machine
c:\Agent\zabbix\zabbix_agentd.exe --uninstall

Write-Host zabbix_agentd has been uninstalled

# Cleans up logs in c:\
Remove-Item c:\Agent\zabbix\zabbix_agentd.log

# Cleans up in c:\
Remove-Item c:\Agent\ -Force -Recurse

# Cleans up logs in c:\
Remove-Item c:\Agent\zabbix\zabbix_agentd.log

# Deletes the Zabbix firewall rule
Remove-NetFirewallRule -DisplayName "Allow Zabbix communication"
