Get-ADComputer -Filter "Name -eq 'TSTIAVW03' -or Name -eq 'TSTISVW03'" -Properties * | select name, objectSid, ObjectGUID | ft
