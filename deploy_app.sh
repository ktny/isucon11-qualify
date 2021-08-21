#!/bin/bash -x

echo "start deploy app ${USER}"

# 配置先
sqldest=/home/isucon/webapp/sql/
godest=/home/isucon/webapp/go/

# GOOS=linux go build -o app src/isucon/app.go
# cd webapp/go
# go build -o isucondition
# cd ../..

for server in isu02; do
    # deploy db
    ssh -tq $server "sudo systemctl stop mariadb"
    ssh -tq $server "sudo rm -f /var/log/mysql/mysql-slow.log"
    ssh -tq $server "mysql -uisucon -pisucon -e'flush logs;' isucondition"
    scp mysql.cnf $server:/etc/mysql/conf.d/mysql.cnf
    scp webapp/sql/0_Schema.sql $server:$sqldest
    scp webapp/sql/1_InitData.sql $server:$sqldest
    ssh -tq $server "/home/isucon/webapp/sql/init.sh"
    ssh -tq $server "sudo systemctl start mariadb"

    # deploy nginx
    scp nginx.conf $server:/etc/nginx/nginx.conf
    ssh -tq $server "sudo rm -f /var/log/nginx/access.log"
    ssh -tq $server "sudo systemctl restart nginx"

    # deploy app
    ssh -tq $server "sudo systemctl stop isucondition.go.service"
    scp webapp/go/main.go $server:$godest
    scp webapp/go/go.mod $server:$godest
    scp webapp/go/go.sum $server:$godest
    ssh -tq $server "cd webapp/go && /home/isucon/local/go/bin/go build -o isucondition"
    ssh -tq $server "sudo systemctl start isucondition.go.service"
    ssh -tq $server "sudo systemctl restart jiaapi-mock.service"
done

echo "finish deploy app ${USER}"
