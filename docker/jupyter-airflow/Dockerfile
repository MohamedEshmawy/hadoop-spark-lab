# Combined Jupyter Lab + Apache Airflow for Teaching Lab
# Merges both images to reduce disk space by eliminating duplicate Hadoop/Spark/Hive installations

FROM jupyter/pyspark-notebook:spark-3.5.0

LABEL maintainer="Hadoop Teaching Lab"
LABEL version="1.0"
LABEL description="Combined Jupyter + Airflow image"

USER root

# Set environment variables
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HIVE_HOME=/opt/hive
ENV HIVE_VERSION=3.1.3
ENV SPARK_VERSION=3.5.0
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SPARK_HOME/bin
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Airflow environment
ENV AIRFLOW_HOME=/opt/airflow
ENV AIRFLOW_VERSION=2.8.1
ENV CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-3.10.txt"

# Install additional dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat \
    netcat-openbsd \
    curl \
    openjdk-11-jdk \
    procps \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hadoop client
RUN curl -fsSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}

# Download and install Hive client (for beeline)
RUN curl -fsSL https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME}

# Create Hadoop configuration directory
RUN mkdir -p ${HADOOP_CONF_DIR}

# Copy Hadoop configurations
COPY config/core-site.xml ${HADOOP_CONF_DIR}/
COPY config/hdfs-site.xml ${HADOOP_CONF_DIR}/
COPY config/yarn-site.xml ${HADOOP_CONF_DIR}/
COPY config/hive-site.xml ${HIVE_HOME}/conf/

# Copy hive-site.xml to Spark conf for Hive Metastore integration
RUN cp ${HIVE_HOME}/conf/hive-site.xml ${SPARK_HOME}/conf/ 2>/dev/null || true

# Create Airflow directories
RUN mkdir -p ${AIRFLOW_HOME}/dags ${AIRFLOW_HOME}/logs ${AIRFLOW_HOME}/plugins

# Install Airflow and providers
RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}" \
    && pip install --no-cache-dir \
    hdfs[avro,dataframe] \
    && pip install --no-cache-dir \
    apache-airflow-providers-apache-spark==4.7.1 \
    apache-airflow-providers-apache-hive==6.4.1 \
    apache-airflow-providers-apache-hdfs==4.3.2 --no-deps \
    && pip install --no-cache-dir \
    pyhive==0.7.0 \
    thrift==0.16.0 \
    thrift-sasl==0.4.3 \
    psycopg2-binary

# Install additional Jupyter Python packages
RUN pip install --no-cache-dir \
    findspark \
    matplotlib \
    seaborn \
    plotly \
    openpyxl \
    faker

# Copy startup scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/jupyter-startup.sh /jupyter-startup.sh
RUN chmod +x /entrypoint.sh /jupyter-startup.sh

# Set ownership
RUN chown -R jovyan:users ${HADOOP_HOME} ${HIVE_HOME} ${AIRFLOW_HOME} /home/jovyan

# Create directories for Jupyter
RUN mkdir -p /home/jovyan/notebooks /home/jovyan/data /home/jovyan/exercises \
    && chown -R jovyan:users /home/jovyan

# Set Spark and Hive environment for Jupyter
ENV PYSPARK_PYTHON=/opt/conda/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/opt/conda/bin/python3
ENV PYSPARK_SUBMIT_ARGS="--master yarn --deploy-mode client --conf spark.yarn.appMasterEnv.PYSPARK_PYTHON=/opt/conda/bin/python3 --conf spark.executorEnv.PYSPARK_PYTHON=/opt/conda/bin/python3 pyspark-shell"
ENV SPARK_CONF_DIR=$SPARK_HOME/conf
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH

# Hive Metastore connection
ENV HIVE_METASTORE_URI=thrift://hive-metastore:9083

WORKDIR /home/jovyan

# Default to Jupyter mode, but can be overridden
ENV SERVICE_MODE=jupyter

CMD ["/entrypoint.sh"]
