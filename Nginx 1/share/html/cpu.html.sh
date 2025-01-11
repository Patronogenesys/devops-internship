#!/bin/sh
# -*- coding: utf-8 -*-
NAME=`"cpuinfo"`
echo "Content-type:text/html\r\n"
cpu=$(top -bn1 | grep "%Cpu(s)" | head -n 1 | awk '{print $2 + $4}')
cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <meta http-equiv="Refresh" content="1">
</head>
<body>
    <h1>CPU Load = $cpu%<h1>
</body>
</html>
EOF