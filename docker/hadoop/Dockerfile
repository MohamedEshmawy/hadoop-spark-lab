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
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda with Python 3.11 for PySpark compatibility with Jupyter
ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-py311_24.1.2-0-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p ${CONDA_DIR} \
    && rm /tmp/miniconda.sh \
    && ${CONDA_DIR}/bin/conda clean -afy \
    && ln -sf ${CONDA_DIR}/bin/python /usr/bin/python3 \
    && ln -sf ${CONDA_DIR}/bin/python /usr/bin/python

ENV PATH=${CONDA_DIR}/bin:$PATH

# Set Python environment for PySpark
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/usr/bin/python3

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

