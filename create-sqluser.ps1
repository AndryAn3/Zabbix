sqlps
$query="create login ZabbixMon with password = 'Fth4hegwg3v4bytytrherwegerrehtyiliew';
GO
EXEC master..sp_addsrvrolemember @loginame = N'ZabbixMon', @rolename = N'sysadmin'
GO"
invoke-Sqlcmd -query $query