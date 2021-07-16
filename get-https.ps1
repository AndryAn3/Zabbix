Import-Module webadministration
iis:
$value = Get-WebBinding -Protocol https | % { $_.bindinginformation }
$array = @()
$array = $value 
$certstocheck = $null
$certstocheck = @()

foreach ($val in $array) {
    $new = $val.split(':') 
    #write-host $new[2]
    if ([string]::IsNullOrWhitespace($new[2])) { continue }
    $certstocheck += $new[2]
}

cd Cert:\LocalMachine\WebHosting
$certsinstore = ls
foreach ($cert in $certstocheck) {
    gci | ? {$_.Subject -imatch $cert} 
    write-host "-------------$cert --------------------"
}

