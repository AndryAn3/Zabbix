omreport storage vdisk controller=0 | ?{$_ -match "^status"} | %{$status=1}{if($_ -notlike "*OK*"){$status=0}}{$status}