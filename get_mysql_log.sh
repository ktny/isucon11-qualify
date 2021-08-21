#!/bin/bash -x

echo "start get log ${USER}"

# 配置先
dest=/home/isucon/webapp/go/isucondition

# GOOS=linux go build -o app src/isucon/app.go
cd webapp/go

ssh -tq isu01 "sudo pt-query-digest /var/log/mysql/mysql-slow.log > /tmp/mysql-`date "+%Y%m%d_%H%M%S"`.log"
scp isu01:/tmp/mysql-*.log ./log/
ssh -tq isu01 "rm -f /tmp/mysql-*.log"

echo "finish get log ${USER}"