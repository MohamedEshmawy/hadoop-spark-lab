#!/bin/bash
set -e

# Configure Spark from environment variables
configure_spark() {
    local spark_defaults="$SPARK_HOME/conf/spark-defaults.conf"

    # Create or truncate file
    > "$spark_defaults"

    # Convert SPARK_CONF_ environment variables
    # Use double underscore (__) to represent dots in property names
    # Single underscore is preserved as underscore
    printenv | grep "^SPARK_CONF_" | while IFS='=' read -r name value; do
        # Remove SPARK_CONF_ prefix and convert __ to .
        prop_name=$(echo "${name#SPARK_CONF_}" | sed 's/__/./g')
        echo "$prop_name $value" >> "$spark_defaults"
    done
}

# Configure Hadoop client for HDFS and YARN access
configure_hadoop_client() {
    mkdir -p $HADOOP_CONF_DIR

    # Set YARN_CONF_DIR to same as HADOOP_CONF_DIR
    export YARN_CONF_DIR=$HADOOP_CONF_DIR

    # Create core-site.xml
    cat > "$HADOOP_CONF_DIR/core-site.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://namenode:9000</value>
    </property>
</configuration>
EOF

    # Create yarn-site.xml with full RM endpoints for Spark-on-YARN
    cat > "$HADOOP_CONF_DIR/yarn-site.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>resourcemanager</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>resourcemanager:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>resourcemanager:8030</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>resourcemanager:8088</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>resourcemanager:8031</value>
    </property>
</configuration>
EOF
}

# Wait for HDFS
wait_for_hdfs() {
    echo "Waiting for HDFS to be ready..."
    while ! nc -z namenode 9000; do
        sleep 2
    done
    echo "HDFS is ready!"
}

# Wait for YARN
wait_for_yarn() {
    echo "Waiting for YARN to be ready..."
    while ! nc -z resourcemanager 8032; do
        sleep 2
    done
    sleep 5  # Extra wait for ResourceManager to fully initialize
    echo "YARN is ready!"
}

# Initialize local Spark log directories (fallback)
init_local_spark_logs() {
    # Create local spark-logs directory as fallback
    mkdir -p /spark-logs
    chmod 777 /spark-logs
    # Also create the default spark-events directory as fallback
    mkdir -p /tmp/spark-events
    chmod 777 /tmp/spark-events
}

# Initialize HDFS spark-logs directory
init_hdfs_spark_logs() {
    echo "Creating /spark-logs directory in HDFS..."
    # Wait a bit for HDFS to be fully ready for writes
    sleep 5

    # Create the spark-logs directory in HDFS if it doesn't exist
    if ! $HADOOP_HOME/bin/hdfs dfs -test -d /spark-logs 2>/dev/null; then
        $HADOOP_HOME/bin/hdfs dfs -mkdir -p /spark-logs
        $HADOOP_HOME/bin/hdfs dfs -chmod 1777 /spark-logs
        echo "Created /spark-logs directory in HDFS with permissions 1777"
    else
        echo "/spark-logs directory already exists in HDFS"
    fi
}

# Start services based on mode
start_services() {
    case "$SPARK_MODE" in
        history)
            wait_for_hdfs
            init_local_spark_logs
            init_hdfs_spark_logs
            # Create local logs directory for Spark daemon logs
            mkdir -p $SPARK_HOME/logs
            echo "Starting Spark History Server..."
            # Run history server in foreground
            exec $SPARK_HOME/bin/spark-class org.apache.spark.deploy.history.HistoryServer --properties-file $SPARK_HOME/conf/spark-defaults.conf
            ;;
        client)
            wait_for_hdfs
            wait_for_yarn
            init_local_spark_logs
            echo "Spark client ready. Container will stay running for interactive use."
            exec tail -f /dev/null
            ;;
        *)
            echo "Unknown Spark mode: $SPARK_MODE"
            exit 1
            ;;
    esac
}

# Main
configure_spark
configure_hadoop_client
start_services

