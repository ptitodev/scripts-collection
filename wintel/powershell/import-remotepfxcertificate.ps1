﻿$session = New-PSSession $Env:ComputerName
Invoke-Command -Session $session -ScriptBlock { Import-PfxCertificate -FilePath "\\ad.sysinfo.io\public\DFS\visualblind\Documents\Sysinfo.io\ssl\sysinfo.io-0001.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password (ConvertTo-SecureString -String "Password" -AsPlainText -Force) }