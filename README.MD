# Hadoop-demo

## 1. Before build
Download resources to ./resources

1. [Oracle JDK 8](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html) ~~[OpenJDK 15 Linux / x64](https://jdk.java.net/15/)~~
2. [Hadoop](https://hadoop.apache.org/releases.html)
3. [Hive](https://hive.apache.org/downloads.html)

## 2. Docker build
```sh
./docker-build
```

## 3. Docker run
```sh
# create network bridge once if haven't create
docker network create hadoop

docker run --name hive_mysql --network hadoop -e MYSQL_ROOT_PASSWORD=dev -p 33060:3306 -d mysql:5.7 
docker run --name hadoop0 --network hadoop -p 8088:8088 -p 9870:9870 -p 10000:10000 -d uhan6/hadoop-demo-master:0.1.0
docker run --name hadoop1 --network hadoop -d uhan6/hadoop-demo-worker:0.1.0
docker run --name hadoop2 --network hadoop -d uhan6/hadoop-demo-worker:0.1.0
```

## 4. Setting Hive mysql metastore
connect to hive_mysql use `root` password `dev`, create user for hive
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
docker exec -it hadoop0 /bin/bash

# run hadoop
hdfs namenode -format
/usr/local/hadoop-3.2.2/sbin/start-dfs.sh
/usr/local/hadoop-3.2.2/sbin/start-yarn.sh

# create folder for hive
hadoop fs -mkdir -p /tmp
hadoop fs -mkdir -p /user/hive/warehouse
hadoop fs -chmod g+w /tmp
hadoop fs -chmod g+w /user/hive/warehouse

# fix hive lib with hadoop lib
rm -f $HIVE_HOME/lib/guava-19.0.jar
cp $HADOOP_HOME/share/hadoop/hdfs/lib/guava-27.0-jre.jar $HIVE_HOME/lib/

# run hive
schematool -initSchema -dbType mysql
hiveserver2
```

## 6. Connect to Hive
```sh
# transportMode=http is important
beeline -u jdbc:hive2://localhost:10000&transportMode=http
```
