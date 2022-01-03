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

cd Cert:\LocalMachine
$certsinstore = ls
foreach ($cert in $certstocheck) {
    gci | ? {$_.Subject -imatch $cert} 
    write-host "-------------$cert --------------------"
    sl cert:
    Get-ChildItem -Recurse | where { $_.subject -like $cert } | where { $_.notafter -le (get-date).AddDays(75) -AND $_.notafter -gt (get-date)} | select thumbprint, subject
}

