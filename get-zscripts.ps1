#get install path
#   Atsi 20-5-2021
#sign PS scripts
#$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert
#$cert = Get-PfxCertificate -FilePath C:\Test\Mysign.pfx
#Set-AuthenticodeSignature -FilePath ServerProps.ps1 -Certificate $cert
try {
$exec = Get-ExecutionPolicy
Set-ExecutionPolicy Bypass -Force -Confirm:$false
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$zabbixdir = Get-ItemProperty -Path "HKLM:\SOFTWARE\Zabbix SIA\Zabbix Agent 2 (64-bit)\"
$zabbixdir2 = $zabbixdir.installfolder
$path = "$zabbixdir2`Scripts\"
$repository =  "https://raw.githubusercontent.com/AndryAn3/Zabbix/main/"
$ZabbixConfig = "$zabbixdir2`zabbix_agent2.conf"
$parameterlist = @'
UserParameter=apppool.discovery,powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get_apppool.ps1"
UserParameter=apppool.state[*],powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get_apppoolstate.ps1" "$1"
UserParameter=site.discovery,powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get_sites.ps1"
UserParameter=site.state[*],powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get_sitestate.ps1" "$1"
UserParameter=ps.run[*],powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\run_script.ps1" "$1"
UserParameter=ps.scripts[*],powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get-zscripts.ps1" "$1"
UserParameter=raid.battery,powershell -nologo "c:\program files\Zabbix Agent 2\Scripts\get-raidbat.ps1"
UserParameter=raid.vdisks,powershell -nologo "c:\program files\Zabbix Agent 2\Scripts\get-raidvdisks.ps1"
UserParameter=raid.disks,powershell -nologo "c:\program files\Zabbix Agent 2\Scripts\get-raiddisks.ps1"
UserParameter=DaysSinceLastUpdate,powershell.exe -NoProfile -ExecutionPolicy bypass -File "c:\program files\Zabbix Agent 2\Scripts\get-lastupdate.ps1" 
'@
If(!(test-path $path)){ New-Item -ItemType Directory -Force -Path $path }
If((test-path "$path\ps.xlm")) { remove-item -Path "$path\ps.xlm" -Force -Confirm:$false  }
gci $path | % { $_.name } >> "$path\ps.xlm"
#Get-AuthenticodeSignature -FilePath $Env:TEMP\list.xxl
$apple = Invoke-WebRequest "https://raw.githubusercontent.com/AndryAn3/Zabbix/main/list.xxl" -UseBasicParsing
$orage = get-content "C:\Program Files\Zabbix Agent 2\scripts\ps.xlm"
$apple.content | Set-Content "$env:TEMP\lkjhhfgd.txt"
$apple = get-Content "$env:TEMP\lkjhhfgd.txt"
$DLlist = Compare-Object $apple $orage -PassThru | Where-Object {$_.SideIndicator -ne "=>"}
$downloaded = $null
    foreach ($item in $DLlist) {
        #write-host $item
        $split = $parameterlist | select-string $item | % { $_.Line -split 'UserParameter='}
        $test =  "$repository" + "$item"
        $xpath =  "$path" + "$item"
        $string = $null
        $bananassplit = $null
        $bananassplits = $null
        $WebClient = New-Object System.Net.WebClient
    	$WebClient.DownloadFile("$test","$xpath")
        $downloaded += "$item downloaded + "
        $string = get-content $ZabbixConfig | select-string $item
        if([string]::IsNullOrEmpty($string)) { 
           $bananassplit = $split | select-string $item 
           $bananassplits = "UserParameter=$bananassplit"
           add-content -Path $ZabbixConfig -value "`n$bananassplits"
        }
}
#AGENT Upgrade PROCESS HERE# OR Seperate script (think preferred)
<#
$CheckInstalled = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "zabbix agent*"}
$exe = "msiexec.exe"
$Arguments = "/i $InstallLocation\$MSIFile HOSTNAME=$hostFQDN SERVER=$ZabbixServer SERVERACTIVE=$ZabbixServer ENABLEPATH=TRUE /qn" #LOGTYPE=system
$AgentVersion = "5.2.5"
    if ($null -ne $CheckInstalled -and $CheckInstalled.Version -lt $AgentVersion){
    Start-Process -FilePath $exe -ArgumentList $Arguments -Wait
    Restart-Service -Name 'Zabbix Agent 2'
    }   #>
}
Restart-Service -Name "Zabbix Agent 2" -Force
catch {
    If ($_.Exception.Response.StatusCode.value__) {
        $crap = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim();
        Write-Output $crap;
    }
    If  ($_.Exception.Message) {
        $crapMessage = ($_.Exception.Message).ToString().Trim();
        Write-Output $crapMessage;
    }
 [System.Net.WebException] { "A NET error occurred. Files were not downloaded."   }
 [System.IO.IOException] { "An IO error occurred. Files were not saved."   }
}
Finally {
    Set-ExecutionPolicy $exec -Force -Confirm:$false
    If((test-path "$env:TEMP\lkjhhfgd.txt")) { remove-item -path "$env:TEMP\lkjhhfgd.txt" -Force -Confirm:$false  }
    If((test-path "$path\ps.xlm")) { remove-item -Path "$path\ps.xlm" -Force -Confirm:$false }
    write-host $downloaded
}

   