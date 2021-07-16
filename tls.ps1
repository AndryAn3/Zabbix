### Created by Andry: ‎vrijdag ‎16 ‎juli ‎2021, ‏‎13:37:32
### last change ‎vrijdag ‎16 ‎juli ‎2021, ‏‎14:54:35 
$key = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 32 |%{[char]$_})
$hostFQDN = ([System.Net.Dns]::GetHostByName(($env:computerName))).HostName
$ZabbixConfig = "zabbix_agent2.conf"
$GetFile = Get-Content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig"
[string]$id = $getfile | Select-String -pattern "TLSPSKIdentity="
if ($id.trim().StartsWith("#")) { 
    $iid = "TLSPSKIdentity=$hostFQDN"
    $GetFile -replace $id, $iid  |  Set-Content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig"  }
    elseif ([string]::IsNullOrEmpty($id)) {        add-content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig" -value "`n$iid"
    }
    #else {     write-host "ID is something else, or already done ofc $id"     }   safety checked
[string]$pskey = $getfile | Select-String -pattern "TLSPSKVALUE="
$psid = "TLSPSKVALUE=$key"
if ($pskey.trim().StartsWith("#")) { 
    $GetFile -replace $pskey, $psid  |  Set-Content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig"  }
    elseif ([string]::IsNullOrEmpty($pskey)) {     add-content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig" -value "`n$psid" } 
    #else {     write-host "Noooooooooo  keyvalue $pskey"    }  safety checked
[string]$tlsa = $getfile | Select-String -pattern "TLSAccept="
$tlsab = "TLSAccept=psk"
if ($tlsa.trim().StartsWith("#")) { 
    $GetFile -replace $tlsa, $tlsab  |  Set-Content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig" 
}
    elseif ([string]::IsNullOrEmpty($tlsa)) {
    add-content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig" -value "`n$tlsab"
} 
    #else {     write-host "Noooooooooo tlsaccept  $tlsa"    }
[string]$tlsc = $getfile | Select-String -pattern "TLSConnect="
$tlsca = "TLSConnect=psk"
if ($tlsc.trim().StartsWith("#")) { 
    $GetFile -replace $tlsc, $tlsca  |  Set-Content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig" 
}
    elseif ([string]::IsNullOrEmpty($tlsc)) {
    add-content -Path "c:\program files\Zabbix Agent 2\$ZabbixConfig" -value "`n$tlsca"
} 
write-host "Use the following PSK Key for the given host: $key"
Restart-Service -Name 'Zabbix Agent 2'  -Force