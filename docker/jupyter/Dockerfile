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

# Install additional dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hadoop client
RUN curl -fsSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}

# Create Hadoop configuration directory
RUN mkdir -p ${HADOOP_CONF_DIR}

# Copy configuration
COPY config/* ${HADOOP_CONF_DIR}/

# Copy startup script
COPY scripts/startup.sh /startup.sh
RUN chmod +x /startup.sh

# Install additional Python packages
RUN pip install --no-cache-dir \
    findspark \
    matplotlib \
    seaborn \
    plotly \
    openpyxl \
    faker

# Create directories
RUN mkdir -p /home/jovyan/notebooks /home/jovyan/data /home/jovyan/exercises \
    && chown -R jovyan:users /home/jovyan

USER jovyan

WORKDIR /home/jovyan

# Set Spark environment
ENV PYSPARK_SUBMIT_ARGS="--master yarn --deploy-mode client pyspark-shell"
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

CMD ["/startup.sh"]

