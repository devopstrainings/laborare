## TO verify the service running or not.

### 1) Check process running or not.
```
# ps -ef | grep <Process - Name>
# ps -ef | grep http
```

### 2) check the port was opened or not.
```
# netstat -lntp 
-l -> Only LISTEN Ports
-n -> Need numbers instaed of names
-t -> TCP ports
-p -> PID of the process whiich opened this port.

```

### 3) Check the service locally 
```
# telnet localhost PORTNO
# telnet localhost 80
```
