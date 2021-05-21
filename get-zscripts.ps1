#get install path
#get source ps1 list
#compare and download all ps1
#sign PS scripts
#$cert=Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert
#$cert = Get-PfxCertificate -FilePath C:\Test\Mysign.pfx
#Set-AuthenticodeSignature -FilePath ServerProps.ps1 -Certificate $cert

$path = "C:\Program Files\Zabbix Agent 2\Scripts"
$repository = "https://lalla.com/repo"
remove-item -Path "$path\ps.xlm" -Force -Confirm:$false  
gci $path | % { $_.name } >> "$path\ps.xlm"
#Get-AuthenticodeSignature -FilePath $Env:TEMP\list.xxl
$apple = get-content "C:\Program Files\Zabbix Agent 2\scripts\list.xxl"  #webaddress later
$orage = get-content "C:\Program Files\Zabbix Agent 2\scripts\ps.xlm"
$DLlist = Compare-Object $apple $orage -PassThru | Where-Object {$_.SideIndicator -ne "=>"}
    foreach ($item in $DLlist) {
        #$WebClient = New-Object System.Net.WebClient
		write-host "$WebClient.DownloadFile("$repository/$item","$path\$item")"
    }