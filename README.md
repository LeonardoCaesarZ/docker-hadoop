## 简述

由于以后的工作会涉及到大数据，故需要熟悉Hadoop。所以，本文将会对Hadoop环境的搭建与使用进行讲解。

## 简易部署

MBP执行shell脚本，快捷地使用docker搭建单机伪分布式Hadoop环境，可用作本地测试环境

1. 安装docker并启动

2. 下载安装包docker-hadoop，并解压

   [地址](https://github.com/LeonardoCaesarZ/docker-hadoop/archive/master.zip)

3. 下载Hadoop，置于docker-hadoop文件夹中解压

   [地址](http://apache.mirrors.pair.com/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz)

4. 制作镜像

   ```
   cd docker-hadoop
   docker build -t caesarz/hadoop .
   ```

5. 执行安装脚本

   ```bash
   bash deploy-all.sh
   ```

6. 执行测试脚本，运行wordcount例子

   ```bash
   bash test.sh
   ```

测试脚本最后会输出如下文本，为统计单词的结果，WARN可不管。至此，Hadoop单机伪分布式环境搭建完成

```
17/12/09 09:49:42 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
6	dfs.audit.logger
4	dfs.class
3	dfs.logger
3	dfs.server.namenode.
2	dfs.audit.log.maxbackupindex
2	dfs.period
2	dfs.audit.log.maxfilesize
1	dfs.replication
1	dfs.log
1	dfs.file
1	dfs.data.dir
1	dfs.servers
1	dfsadmin
1	dfsmetrics.log
1	dfs.name.dir
```

## 详细部署

> ⚠️：并未经过测试

真 · 分布式搭建：拥有N台物理机，1台作master机，N-1台作slave机。docker仓库应提前准备，各物理机应与仓库建立联系，每台物理机运行一个Hadoop容器。本方案用于生产环境

1. 启动docker

   > 各机执行

   ```bash
   service docker start
   ```

2. 按需修改各配置文件

   > master机执行

   ```bash
   cd ~
   wget ...			// 下载部署安装包
   cd docker-hadoop
   vi hosts			// 一般来讲，只需要修改这个文件
   vi depoly.sh		// 在docker run语句中使用-p来映射需要的端口
   vi core-site.xml	// 可不修改
   vi hdfs-site.xml	// 可不修改
   vi mapred-site.xml	// 可不修改
   vi yarn-site.xml	// 可不修改
   ```

3. 构建镜像，并上传仓库

   > master机执行

   ```bash
   docker build -t caesarz/hadoop .
   docker push	caesarz/hadoop	// 上传至仓库
   ```

4. master机启动容器，并将容器的ssh公钥复制到docker-hadoop/authorized_keys中

   > master机执行

   ```bash
   bash deploy.sh [absolute/path/to/share/dir] master
   docker exec hadoop-master cat /root/.ssh/authorized_keys > ./authorized_keys
   ```

5. 压缩docker-hadoop文件夹，传至各slave机，各slave机下载镜像并启动

   > master机

   ```bash
   cd ~
   tar czf docker-hadoop-completed.tar.gz docker-hadoop/*
   ```

   > 各slave机

   ```bash
   cd ~
   scp root@[ip.of.master.machine]:~/docker-hadoop-completed.tar.gz ./docker-hadoop.tar.gz
   tar zxf docker-hadoop.tar.gz
   cd docker-hadoop
   docker pull caesarz/hadoop
   bash deploy.sh [absolute/path/to/share/dir] slave[1,2,3,...]
   ```

6. 初始化HDFS

   > master机

   ```bash
   docker exec -it hadoop-master bash -c 'source /root/.bashrc; bash /root/onekey.sh'
   docker exec -it hadoop-master bash -c 'source /root/.bashrc; bash $HADOOP_HOME/sbin/start-all.sh'
   docker exec -it hadoop-master bash -c 'source /root/.bashrc; hadoop dfs -mkdir -p /user/root'
   ```

7. 执行测试脚本，运行wordcount例子

   > master机

   ```bash
   cd docker-hadoop
   bash test.sh
   ```
