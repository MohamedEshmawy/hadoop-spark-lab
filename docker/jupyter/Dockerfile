# Jupyter Lab with PySpark for Teaching Lab
FROM jupyter/pyspark-notebook:spark-3.5.0

LABEL maintainer="Hadoop Teaching Lab"
LABEL version="1.0"

USER root

# Set environment variables
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin

# Install additional dependencies and Java 11 (to match Hadoop cluster)
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat \
    curl \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hadoop client
RUN curl -fsSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}

# Create Hadoop configuration directory
RUN mkdir -p ${HADOOP_CONF_DIR}

# Copy configuration to Hadoop conf dir
COPY config/* ${HADOOP_CONF_DIR}/

# Copy hive-site.xml to Spark conf for Hive Metastore integration
RUN cp ${HADOOP_CONF_DIR}/hive-site.xml /usr/local/spark/conf/ 2>/dev/null || true

# Copy startup script
COPY scripts/startup.sh /startup.sh
RUN chmod +x /startup.sh

# Install additional Python packages including Hive connectivity
RUN pip install --no-cache-dir \
    findspark \
    matplotlib \
    seaborn \
    plotly \
    openpyxl \
    faker \
    pyhive \
    thrift \
    thrift-sasl \
    sasl

# Create directories
RUN mkdir -p /home/jovyan/notebooks /home/jovyan/data /home/jovyan/exercises \
    && chown -R jovyan:users /home/jovyan

USER jovyan

WORKDIR /home/jovyan

# Set Spark and Hive environment
# Use an explicit Python path so executors on YARN NodeManagers can find it
ENV PYSPARK_PYTHON=/opt/conda/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/opt/conda/bin/python3
ENV PYSPARK_SUBMIT_ARGS="--master yarn --deploy-mode client --conf spark.yarn.appMasterEnv.PYSPARK_PYTHON=/opt/conda/bin/python3 --conf spark.executorEnv.PYSPARK_PYTHON=/opt/conda/bin/python3 pyspark-shell"
ENV SPARK_HOME=/usr/local/spark
ENV SPARK_CONF_DIR=$SPARK_HOME/conf
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Hive Metastore connection (also set in hive-site.xml)
ENV HIVE_METASTORE_URI=thrift://hive-metastore:9083

CMD ["/startup.sh"]

