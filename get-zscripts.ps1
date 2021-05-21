#get install path
#get source ps1 list
#compare and download all ps1
#sign PS scripts
#$cert=Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert
#$cert = Get-PfxCertificate -FilePath C:\Test\Mysign.pfx
#Set-AuthenticodeSignature -FilePath ServerProps.ps1 -Certificate $cert
try {
$path = "C:\Program Files\Zabbix Agent 2\Scripts\"
$repository =  "https://raw.githubusercontent.com/AndryAn3/Zabbix/main/"
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
        $WebClient = New-Object System.Net.WebClient
    	$WebClient.DownloadFile("$test","$xpath")
        $downloaded += "$item +"
     }
}
catch {
    [System.Net.WebException],[System.IO.IOException] {        "An error occurred. Files $_ were not downloaded."   }
}
Finally {
    remove-item -path "$env:TEMP\lkjhhfgd.txt" -Force -Confirm:$false  
    remove-item -Path "$path\ps.xlm" -Force -Confirm:$false 
    write-host $downloaded
}

   