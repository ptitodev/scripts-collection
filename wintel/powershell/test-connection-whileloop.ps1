﻿while($true){
     test-connection 8.8.8.8, sysinfo.io, 4.2.2.1 -count 1 
     sleep -MilliSeconds 1000 |
     select @{N='Time';E={[dateTime]::Now}},
          @{N='Destination';E={$_.address}},
          replysize,
          @{N='Time(ms)'; E={$_.ResponseTime}}
}
Set-ExecutionPolicy 0