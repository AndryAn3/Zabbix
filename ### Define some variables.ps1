### Define some variables
$server = 'localhost'
$Password = "Password"
$Database = 'TheBeardsDatabase'
#$Admins = Get-Content 'C:\temp\Admins.txt'
#$Users = Get-Content 'C:\temp\Users.txt'
$LoginType = 'SQLLogin'
$userrole =  'Users'
$adminrole = 'Admin'

# Create a SQL Server SMO Object
$srv = Connect-DbaSqlServer -SqlServer $server
$db = $srv.Databases[$Database]

function Add-UserToRole
{
param
(
[Parameter(Mandatory=$true,
ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true,
ValueFromRemainingArguments=$false)]
[ValidateNotNullOrEmpty()]
[string]$Password,
[Parameter(Mandatory=$true,
ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true,
ValueFromRemainingArguments=$false)]
[ValidateNotNullOrEmpty()]
[string]$User,
[Parameter(Mandatory=$true,
ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true,
ValueFromRemainingArguments=$false)]
[ValidateNotNullOrEmpty()]
[string]$Server,
[Parameter(Mandatory=$true,
ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true,
ValueFromRemainingArguments=$false)]
[ValidateNotNullOrEmpty()]
[string]$Role,
[Parameter(Mandatory=$true,
ValueFromPipeline=$true,
ValueFromPipelineByPropertyName=$true,
ValueFromRemainingArguments=$false)]
[ValidateSet("SQLLogin", "WindowsGroup", "WindowsUser")]
[string]$LoginType
)

if(!($srv.Logins.Contains($User)))
{
if($LoginType -eq 'SQLLogin')
{
$Pass = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Pass
Add-SqlLogin -ServerInstance $Server -LoginName $User -LoginType $LoginType -DefaultDatabase tempdb -Enable -GrantConnectSql -LoginPSCredential $Credential
}
elseif($LoginType -eq 'WindowsGroup' -or $LoginType -eq 'WindowsUser')
{
Add-SqlLogin -ServerInstance $Server -LoginName $User -LoginType $LoginType -DefaultDatabase tempdb -Enable -GrantConnectSql
}
}
if (!($db.Users.Contains($User)))
{

# Add user to database

$usr = New-Object ('Microsoft.SqlServer.Management.Smo.User') ($db, $User)
$usr.Login = $User
$usr.Create()

}
#Add User to the Role
$db.roles[$role].AddMember($User)
}

foreach($User in $Users)
{
Add-UserToRole -Password $Password -User $user -Server $server -Role $Userrole -LoginType SQLLogin
}

foreach($User in $Admins)
{
Add-UserToRole -Password $Password -User $user -Server $server -Role $adminrole -LoginType SQLLogin
}

Get-DbaRoleMember -SqlInstance $server |ogv