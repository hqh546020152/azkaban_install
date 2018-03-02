#!/bin/bash
# 

 
cicd_git(){
         git --version  &> /dev/null
         [ $? -eq 0 ] && echo "git已安装完毕" && return 0
         yum install -y git
} 

cicd_git
DIR=`pwd`
A=`cat create_keystore.txt`
java -version &> /dev/null
[ $? -ne 0 ] && echo "没java环境，无法运行" && exit 2

cd ~
git clone https://github.com/azkaban/azkaban.git
cd  azkaban
./gradlew distTar
cp /root/azkaban/azkaban-*/build/distributions/*.tar.gz  /opt


ls /opt/azkaban-exec-server-3.*.tar.gz &> /dev/null
[ $? -ne 0 ] && echo "缺少文件1" && exit 2
ls /opt/azkaban-web-server-3.*.tar.gz &> /dev/null
[ $? -ne 0 ] && echo "缺少文件2" && exit 2
ls /opt/azkaban-db-3.*.tar.gz &> /dev/null 
[ $? -ne 0 ] && echo "缺少文件3" && exit 2
ls /opt/azkaban-solo-server-3.*.tar.gz &> /dev/null
[ $? -ne 0 ] && echo "缺少文件4" && exit 2

cd /opt
echo "请创建azkaban数据库 并将`ls /opt/azkaban-db-3*/create-all-sql-*` 文件导入azkaban数据库中"
	#mysql> CREATE DATABASE azkaban;
	#mysql> CREATE USER 'azkaban'@'%' IDENTIFIED BY 'azkaban';
	#mysql> flush privileges;
	#cd /opt/azkaban-db-3.*
	#mysql -u azkaban -p azkaban < create-all-sql-3.44.0-2-ga7b0fa4.sql

cd /opt/azkaban-web-server-3.*
echo "请创建认证文件，参考如下
$A"
keytool -keystore keystore -alias jetty -genkey -keyalg RSA

cp -rp /opt/azkaban-solo-server-3.*/conf /opt/azkaban-web-server-3.*/
cp $DIR/log4j.properties /opt/azkaban-web-server-3.*/conf/
cat $DIR/azkaban.properties-web > /opt/azkaban-web-server-3.*/conf/azkaban.properties

cp -rp /opt/azkaban-web-server-3.*/conf /opt/azkaban-exec-server-3.*/
cat $DIR/azkaban.properties-exec > /opt/azkaban-exec-server-3.*/conf/azkaban.properties

echo "已安装完毕，请调整azkaban-exec-server与azkaban-web-server中的azkaban.properties文件，特别为文件路径与连接数据库信息"


#运行
#1、启动azkaban-exec
#	cd /opt/azkaban-exec-server-3.*
#	sh bin/start-executor.sh
#2、启动azkaban-web
#	cd /opt/azkaban-web-server-3.*/bin
#	sh start-web.sh

#访问：HTTPS://localhost:8443
#账号/密码:azkaban/azkaban
#备注：账号密码在/opt/azkaban-exec-server-3.*/conf/azkaban-users.xml中定义


#注意事项（参考启动返回信息）:
#1、配置文件中定义文件需要使用绝对路径。
#2、web exec使用的端口被占用。
#3、配置集群时开启azkaban-exec-server主配置文件中以下选项
#	azkaban.use.multiple.executors=true
#	azkaban.executorselector.filters=StaticRemainingFlowSize,MinimumFreeMemory,CpuStatus
#	azkaban.executorselector.comparator.NumberOfAssignedFlowComparator=1
#	azkaban.executorselector.comparator.Memory=1
#	azkaban.executorselector.comparator.LastDispatched=1
#	azkaban.executorselector.comparator.CpuUsage=1
 	
#	重启azkaban-exec-server，并进入azkaban数据库中执行如下SQL语句，才能完成集群配置，否则不会将执行任务分配到其他节点上。
#	insert into executors(host,port) values("10.10.10.2",12321);
#4、azkaban-web-server启动时以下的报错不影响使用。
#	ERROR PluginCheckerAndActionsLoader:40 - plugin path plugins/triggers doesn't exist!


#文件清理
#rm -fr /opt/azkaban-exec-server-3.*.tar.gz
#rm -fr /opt/azkaban-web-server-3.*.tar.gz
#rm -fr /opt/azkaban-db-3.*.tar.gz
#rm -fr /opt/azkaban-solo-server-3.*
