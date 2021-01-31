FROM centos:7

### sshd and net
RUN yum install -y net-tools
RUN yum install -y openssh-server sudo
RUN yum install -y openssh-clients
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa >> /etc/ssh/ssh_host_rsa_key
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 /etc/ssh/ssh_host_rsa_key

### JDK 8
ADD resources/jdk-8u281-linux-x64.tar.gz /usr/local/

ENV JAVA_HOME /usr/local/jdk1.8.0_281
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$JAVA_HOME/bin

### Hadoop 3.2.2
ADD resources/hadoop-3.2.2.tar.gz /usr/local/

ENV HADOOP_HOME /usr/local/hadoop-3.2.2
ENV PATH $HADOOP_HOME/bin:$PATH

ADD hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
RUN echo $'export JAVA_HOME=/usr/local/jdk1.8.0_281 \n\
    export HDFS_NAMENODE_USER="root"\n\
    export HDFS_DATANODE_USER="root"\n\
    export HDFS_SECONDARYNAMENODE_USER="root"\n\
    export YARN_RESOURCEMANAGER_USER="root"\n\
    export YARN_NODEMANAGER_USER="root"' > $HADOOP_HOME/etc/hadoop/hadoop-env.sh

CMD ["/usr/sbin/sshd", "-D"]
