#!/bin/bash

set -e 

docker exec -it hadoop-master bash -c 'source /root/.bashrc; hdfs dfs -put $HADOOP_HOME/etc/hadoop input'
docker exec -it hadoop-master bash -c 'source /root/.bashrc; hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar grep input output "dfs[a-z.]+"'
docker exec -it hadoop-master bash -c 'source /root/.bashrc; hadoop dfs -cat output/part-r-00000'