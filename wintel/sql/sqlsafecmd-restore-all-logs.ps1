$logs = Get-ChildItem -Path "e:\logship\*.*" -Include *.safe
$sqlcmd = "C:\Program Files\Idera\SQLsafe\SQLsafeCmd.exe"

$a = 'restore'
$b = 'Millennium'
$c = '-RecoveryMode'
$d = 'NoRecovery'

foreach ($log in $logs)
{
#write-host $log.FullName
#& $sqlcmd restore Millennium $log.FullName -RecoveryMode NoRecovery
&$sqlcmd restore Millennium $log.FullName $c $d
#cmd /c $sqlcmd "restore Millennium $log.FullName -RecoveryModeNo Recovery"
}