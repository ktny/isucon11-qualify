#!/bin/bash -x

echo "start deploy db ${USER}"

dest=/home/isucon/webapp/sql/

for server in isu01; do
    ssh -tq $server "sudo systemctl stop mariadb"
    ssh -tq $server "sudo rm -f /var/log/mysql/mysql-slow.log"
    ssh -tq $server "mysql -uisucon -pisucon -e'flush logs;' isucondition"
    scp mysql.cnf $server:/etc/mysql/conf.d/mysql.cnf
    scp webapp/sql/0_Schema.sql $server:$dest
    scp webapp/sql/1_InitData.sql $server:$dest
    ssh -tq $server "/home/isucon/webapp/sql/init.sh"
    ssh -tq $server "sudo systemctl start mariadb"
done

echo "finish deploy db ${USER}"