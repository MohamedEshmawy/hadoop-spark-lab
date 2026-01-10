# Apache Hive for Teaching Lab
FROM eclipse-temurin:11-jdk-focal

LABEL maintainer="Hadoop Teaching Lab"
LABEL version="1.0"

# Set environment variables
ENV HADOOP_VERSION=3.3.6
ENV HIVE_VERSION=3.1.3
ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin
ENV JAVA_HOME=/opt/java/openjdk

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    netcat \
    procps \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hadoop
RUN curl -fsSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}

# Download and install Hive
RUN curl -fsSL https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME}

# Download PostgreSQL JDBC driver for metastore
RUN curl -fsSL https://jdbc.postgresql.org/download/postgresql-42.6.0.jar \
    -o ${HIVE_HOME}/lib/postgresql-42.6.0.jar

# Fix Guava version conflict (Hive ships with older Guava, Hadoop needs newer)
RUN rm -f ${HIVE_HOME}/lib/guava-*.jar \
    && cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-*.jar ${HIVE_HOME}/lib/

# Create necessary directories
RUN mkdir -p ${HADOOP_CONF_DIR} /user/hive/warehouse /tmp/hive

# Copy configurations
COPY config/* ${HIVE_HOME}/conf/

# Copy Hadoop config (will be expanded by entrypoint)
COPY config/core-site.xml ${HADOOP_CONF_DIR}/
COPY config/hdfs-site.xml ${HADOOP_CONF_DIR}/

# Copy entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR ${HIVE_HOME}

ENTRYPOINT ["/entrypoint.sh"]

