#!/bin/bash
yum -y install gcc gcc-c++ zlib-devel make cmake ncurses-devel libjpeg-turbo-devel libpng-devel gd perl glibc libxml2-devel libcurl-devel libtool
tar -zxf httpd-2.2.9.tar.gz
cd httpd-2.2.9
./configure --prefix=/usr/local/apache --enable-so && make && make install
if [ $? -ne 0 ];then
        echo "源码包执行错误"
fi
APACHE=`/usr/local/apache/bin/apachectl restart`
/usr/local/apache/bin/apachectl start
if [ $? -ne 0 ];then
     echo "httpd启动没成功"
else
     echo "$APACHE"
     echo "httpd启动成功"
fi
cd /root
#################MYSQL#############
tar -zxf mysql-5.6.15.tar.gz
cd mysql-5.6.15
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql && make && make install
cd /usr/local/mysql/
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
cp support-files/my-default.cnf /etc/my.cnf
useradd -s /sbin/nologin mysql
chown -R mysql.mysql /usr/local/mysql
/usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/data/ --basedir=/usr/local/mysql/
service mysqld start
if [ $? -ne 0 ];then
        echo "MYSQL启动失败"
   else
        service mysqld restart
        echo"MYSQL启动成功"
fi
FUWU=`lsof -i:3306|grep 'mysqld'|awk '{print $1}'`
if [ $? -eq 0 ];then
        echo "$FUWU端口:3306"
fi
ln -s /usr/local/mysql/bin/* /usr/local/sbin/
cd /root
###############PHP#################
tar -zxf  php-5.3.10.tar.gz
cd php-5.3.10
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache/bin/apxs --with-gd-dir=/usr/lib --with-ttf --with-zlib-dir --with-jpeg-dir --with-png-dir --with-mysql=/usr/local/mysql && make && make install
if [ $? -ne 0 ];then
        echo "PHP安装错误"
fi
cp php.ini-development /usr/local/php/etc/php.ini
cd /root
chmod -R 755 /usr/local/apache/modules/libphp5.so
sed -i '/AddType application\/x-gzip .gz .tgz/a\AddType application\/x-httpd-php .php' /usr/local/apache/conf/httpd.conf
sed -i "s/DirectoryIndex index.html/DirectoryIndex index.html index.php/g" /usr/local/apache/conf/httpd.conf
rm -rf /usr/local/apache/htdocs/*
cat >>/usr/local/apache/htdocs/index.php<<eof
<?php
phpinfo();
?>
eof
IP=`ifconfig eth0|grep "inet addr"|awk '{print $2}'|awk -F: '{print $2}'`
/usr/local/apache/bin/apachectl restart >>/dev/null
if [ $? -ne 0 ];then
      echo "httpd服务失败"
  else
      echo "请输入$IP访问"
fi
