#get install path
#   Atsi 20-5-2021
#sign PS scripts
#$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert
#$cert = Get-PfxCertificate -FilePath C:\Test\Mysign.pfx
#Set-AuthenticodeSignature -FilePath ServerProps.ps1 -Certificate $cert
try {
$path = "C:\Program Files\Zabbix Agent 2\Scripts\"
$repository =  "https://raw.githubusercontent.com/AndryAn3/Zabbix/main/"
$ZabbixConfig = "c:\program files\Zabbix Agent 2\zabbix_agent2.conf"
$parameterlist = @'
UserParameter=apppool.discovery,powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get_apppool.ps1"
UserParameter=apppool.state[*],powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get_apppoolstate.ps1" "$1"
UserParameter=site.discovery,powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get_sites.ps1"
UserParameter=site.state[*],powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get_sitestate.ps1" "$1"
UserParameter=ps.run[*],powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\run_script.ps1" "$1"
UserParameter=ps.scripts[*],powershell -NoProfile -ExecutionPolicy Bypass -File "c:\program files\Zabbix Agent 2\Scripts\get-zscripts.ps1" "$1"
'@
$split = $parameterlist | select-string $item | % { $_.Line -split 'UserParameter='}
If(!(test-path $path)){ New-Item -ItemType Directory -Force -Path $path }
If((test-path "$path\ps.xlm")) { remove-item -Path "$path\ps.xlm" -Force -Confirm:$false  }
gci $path | % { $_.name } >> "$path\ps.xlm"
#Get-AuthenticodeSignature -FilePath $Env:TEMP\list.xxl
$apple = Invoke-WebRequest "https://raw.githubusercontent.com/AndryAn3/Zabbix/main/list.xxl" 
$orage = get-content "C:\Program Files\Zabbix Agent 2\scripts\ps.xlm"
$apple.content | Set-Content "$env:TEMP\lkjhhfgd.txt"
$apple = get-Content "$env:TEMP\lkjhhfgd.txt"
$DLlist = Compare-Object $apple $orage -PassThru | Where-Object {$_.SideIndicator -ne "=>"}
$downloaded = $null
    foreach ($item in $DLlist) {
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
}
catch {
    [System.Net.WebException],[System.IO.IOException] {        "An error occurred. Files were not downloaded."   }
}
Finally {
    remove-item -path "$env:TEMP\lkjhhfgd.txt" -Force -Confirm:$false  
    remove-item -Path "$path\ps.xlm" -Force -Confirm:$false 
    write-host $downloaded
}

   