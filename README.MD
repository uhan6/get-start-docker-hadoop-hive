# Hadoop-demo

## 1. Before build
Download resources to ./resources

1. [Oracle JDK 8 1.8.281](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html) ~~[OpenJDK 15 Linux / x64](https://jdk.java.net/15/)~~
2. [Hadoop 3.2.2](https://hadoop.apache.org/releases.html)
3. [Hive 3.1.2](https://hive.apache.org/downloads.html)

## 2. Docker build
```sh
./docker-build
```

## 3. Docker run
```sh
# create network bridge once if haven't create
docker network create hadoop

docker run --name hive-meta-mysql --network hadoop -e MYSQL_ROOT_PASSWORD=dev -p 33060:3306 -d mysql:5.7 
docker run --name hadoop-master --network hadoop -p 8088:8088 -p 9870:9870 -p 10000:10000 -d uhan6/hadoop-master:0.1.1
docker run --name hadoop-worker --network hadoop -d uhan6/hadoop-worker:0.1.1
```

## 4. Setting Hive mysql metastore
connect to hive-meta-mysql use `root` password `dev`, create user for hive
```sql
CREATE DATABASE IF NOT EXISTS metastore;
CREATE USER IF NOT EXISTS 'hive'@'%' IDENTIFIED BY 'dev';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'%';
GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'%';

FLUSH PRIVILEGES;
```

## 5. Start hadoop-master and hive
```sh
# into master
docker exec -it hadoop-master /bin/bash

# run hadoop
/usr/local/hadoop-3.2.2/sbin/start-all.sh
# replace by run start-all.sh
# hdfs namenode -format
# /usr/local/hadoop-3.2.2/sbin/start-dfs.sh
# /usr/local/hadoop-3.2.2/sbin/start-yarn.sh

# create folder for hive
hadoop fs -mkdir -p /tmp
hadoop fs -mkdir -p /user/hive/warehouse
hadoop fs -chmod g+w /tmp
hadoop fs -chmod g+w /user/hive/warehouse

# fix hive lib with hadoop lib
rm -f $HIVE_HOME/lib/guava-19.0.jar
cp $HADOOP_HOME/share/hadoop/hdfs/lib/guava-27.0-jre.jar $HIVE_HOME/lib/

# init hive and run hive in background
schematool -initSchema -dbType mysql
nohup hiveserver2 > hiveserver2.log  2>&1 &
```

## 6. Connect to Hive
connect to hive use `hive` password `dev`
```sh
# transportMode=http is important
beeline -u jdbc:hive2://localhost:10000&transportMode=http
```
