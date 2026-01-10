# Spark Image for Teaching Lab
FROM eclipse-temurin:11-jdk-focal

LABEL maintainer="Hadoop Teaching Lab"
LABEL version="1.0"

# Set environment variables
ENV SPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3.3.6
ENV SPARK_HOME=/opt/spark
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin:$HADOOP_HOME/bin
ENV JAVA_HOME=/opt/java/openjdk
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip
ENV PYSPARK_PYTHON=python3

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    netcat \
    python3 \
    python3-pip \
    procps \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hadoop (for client libraries)
RUN curl -fsSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}

# Download and install Spark
RUN curl -fsSL https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    | tar -xz -C /opt/ \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} \
    && mkdir -p /spark-logs

# Copy configuration
COPY config/* ${SPARK_HOME}/conf/
COPY scripts/entrypoint.sh /entrypoint.sh

# Create Hadoop config directory (config is generated at runtime by entrypoint)
RUN mkdir -p ${HADOOP_CONF_DIR}

RUN chmod +x /entrypoint.sh

# Install Python packages for PySpark
RUN pip3 install --no-cache-dir numpy pandas pyarrow

WORKDIR ${SPARK_HOME}

ENTRYPOINT ["/entrypoint.sh"]

