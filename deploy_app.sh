#!/bin/bash -x

echo "start deploy app ${USER}"

# 配置先
dest=/home/isucon/webapp/go/isucondition

# GOOS=linux go build -o app src/isucon/app.go
cd webapp/go
go build -o isucondition

for server in isu01; do
    ssh -tq $server "sudo systemctl stop isucondition.go.service"
    scp ./isucondition $server:$dest
    ssh -tq $server "sudo systemctl start isucondition.go.service"
    ssh -tq $server "sudo systemctl restart jiaapi-mock.service"
done

echo "finish deploy app ${USER}"