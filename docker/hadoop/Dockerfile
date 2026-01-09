# Hadoop Base Image for Teaching Lab
FROM eclipse-temurin:11-jdk-focal

LABEL maintainer="Hadoop Teaching Lab"
LABEL version="1.0"

# Set environment variables
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV JAVA_HOME=/opt/java/openjdk

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    netcat \
    net-tools \
    procps \
    ssh \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hadoop
RUN curl -fsSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar -xz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && mkdir -p /hadoop/dfs/name /hadoop/dfs/data /hadoop/logs

# Copy configuration files
COPY config/* ${HADOOP_CONF_DIR}/
COPY scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Create hadoop user
RUN groupadd -r hadoop && useradd -r -g hadoop hadoop \
    && chown -R hadoop:hadoop /hadoop ${HADOOP_HOME}

WORKDIR ${HADOOP_HOME}

ENTRYPOINT ["/entrypoint.sh"]

