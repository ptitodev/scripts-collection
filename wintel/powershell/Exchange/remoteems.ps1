$UserCredential = Get-credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://exc-a/PowerShell/ -Authentication Kerberos -Credential $UserCredential

Import-PSSession $Session

Get-PSSession

get-user

Remove-PSSession –id <ID# found from previous step>
