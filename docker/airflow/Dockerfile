# Apache Airflow for Teaching Lab
FROM apache/airflow:2.8.1-python3.10

LABEL maintainer="Hadoop Teaching Lab"
LABEL version="1.0"

USER root

# Set environment variables
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HIVE_HOME=/opt/hive
ENV HIVE_VERSION=3.1.3
ENV SPARK_VERSION=3.5.0
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SPARK_HOME/bin
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install Java and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless \
    curl \
    netcat-openbsd \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hadoop client
RUN curl -fsSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}

# Download and install Spark
RUN curl -fsSL https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    | tar -xz -C /opt/ \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME}

# Download and install Hive client (for beeline)
RUN curl -fsSL https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME}

# Create config directories
RUN mkdir -p ${HADOOP_CONF_DIR} ${SPARK_HOME}/conf

# Copy configurations
COPY config/core-site.xml ${HADOOP_CONF_DIR}/
COPY config/hdfs-site.xml ${HADOOP_CONF_DIR}/
COPY config/yarn-site.xml ${HADOOP_CONF_DIR}/
COPY config/hive-site.xml ${HIVE_HOME}/conf/

# Set ownership for airflow user
RUN chown -R airflow:root ${HADOOP_HOME} ${SPARK_HOME} ${HIVE_HOME}

USER airflow

# Install Airflow providers for Hadoop ecosystem
# Note: Install hdfs without kerberos extras first to avoid gssapi build issues
# The HDFS provider requires hdfs[avro,dataframe,kerberos] but we skip kerberos
RUN pip install --no-cache-dir \
    hdfs[avro,dataframe] \
    && pip install --no-cache-dir \
    apache-airflow-providers-apache-spark==4.7.1 \
    apache-airflow-providers-apache-hive==6.4.1 \
    apache-airflow-providers-apache-hdfs==4.3.2 --no-deps \
    && pip install --no-cache-dir \
    pyhive==0.7.0 \
    thrift==0.16.0 \
    thrift-sasl==0.4.3 \
    pyspark==${SPARK_VERSION}

WORKDIR /opt/airflow

