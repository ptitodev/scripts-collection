Get-ChildItem | Where-Object { $_.PSIsContainer } | ForEach-Object { Invoke-Expression -Command ([string]::concat("net share ",$_,"=",(Get-Location).Path,"\",$_," ""/GRANT:DOMAIN\Group1,CHANGE"" ""/GRANT:DOMAIN\Group2,CHANGE"" ""/GRANT:DOMAIN\username,READ"""))}