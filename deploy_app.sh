#!/bin/bash -x

echo "start deploy app ${USER}"

# 配置先
dest=/home/isucon/webapp/go/isucondition

# GOOS=linux go build -o app src/isucon/app.go
go build -o isucondition

for server in isu01; do
    # deploy db
    ssh -tq $server "sudo systemctl stop mariadb"
    ssh -tq $server "sudo rm -f /var/log/mysql/mysql-slow.log"
    ssh -tq $server "mysql -uisucon -pisucon -e'flush logs;' isucondition"
    scp mysql.cnf $server:/etc/mysql/conf.d/mysql.cnf
    scp webapp/sql/0_Schema.sql $server:$dest
    scp webapp/sql/1_InitData.sql $server:$dest
    ssh -tq $server "/home/isucon/webapp/sql/init.sh"
    ssh -tq $server "sudo systemctl start mariadb"

    # deploy app
    ssh -tq $server "sudo systemctl stop isucondition.go.service"
    scp webapp/go/isucondition $server:$dest
    ssh -tq $server "sudo systemctl start isucondition.go.service"
    ssh -tq $server "sudo systemctl restart jiaapi-mock.service"
done

echo "finish deploy app ${USER}"