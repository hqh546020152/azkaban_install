#本目录下的为已配置的安装包，仅供参考。版本为3.44.0.2

#运行条件
1、已有jdk1.8以上环境
2、本机已安装好HADOOP（非必要，但需要定义以下的环境变量，否则报错）
	export HADOOP_HOME=/opt/hadoop
3、本地已安装MySQL5.6以上版本，并创建好azkaban数据库，连接信息如下。
	database.type=mysql
	mysql.port=3306
	mysql.host=localhost
	mysql.database=azkaban
	mysql.user=azkaban
	mysql.password=azkaban
4、初始化azkaban数据库，将create-all-sql-3.44.0-2-ga7b0fa4.sql中的数据信息导入进azkaban库
5、azkaban-exec-server-3.44.tar.gz和azkaban-web-server-3.44.tar.gz程序包解压在/pot目录下
6、keystore认证文件密码为：azkaban
	存放于/opt/azkaban-web-server-3.44.0-2-ga7b0fa4目录下


运行
1、启动azkaban-exec
	cd /opt/azkaban-exec-server-3.44.0-2-ga7b0fa4/bin
	sh start-executor.sh
2、启动azkaban-web
	cd /opt/azkaban-web-server-3.44.0-2-ga7b0fa4/bin
	sh start-web.sh

访问：HTTPS://localhost:8443
账号/密码:azkaban/azkaban
备注：账号密码在/opt/azkaban-exec-server-3.44.0-2-ga7b0fa4/conf/azkaban-users.xml中定义


注意事项（参考启动返回信息）:
1、配置文件中定义文件需要使用绝对路径。
2、web exec使用的端口被占用。
3、配置集群时开启azkaban-exec-server主配置文件中以下选项
	azkaban.use.multiple.executors=true
	azkaban.executorselector.filters=StaticRemainingFlowSize,MinimumFreeMemory,CpuStatus
	azkaban.executorselector.comparator.NumberOfAssignedFlowComparator=1
	azkaban.executorselector.comparator.Memory=1
	azkaban.executorselector.comparator.LastDispatched=1
	azkaban.executorselector.comparator.CpuUsage=1
 	
	重启azkaban-exec-server，并进入azkaban数据库中执行如下SQL语句，才能完成集群配置，否则不会将执行任务分配到其他节点上。
	insert into executors(host,port) values("10.10.10.2",12321);
4、azkaban-web-server启动时以下的报错不影响使用。
	ERROR PluginCheckerAndActionsLoader:40 - plugin path plugins/triggers doesn't exist!



