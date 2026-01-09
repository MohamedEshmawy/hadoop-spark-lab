#!/bin/bash
set -e

# Configure Spark from environment variables
configure_spark() {
    local spark_defaults="$SPARK_HOME/conf/spark-defaults.conf"
    
    # Create or truncate file
    > "$spark_defaults"
    
    # Convert SPARK_CONF_ environment variables
    printenv | grep "^SPARK_CONF_" | while IFS='=' read -r name value; do
        prop_name=$(echo "${name#SPARK_CONF_}" | sed 's/_/./g' | tr '[:upper:]' '[:lower:]')
        echo "$prop_name $value" >> "$spark_defaults"
    done
}

# Configure Hadoop client for HDFS access
configure_hadoop_client() {
    mkdir -p $HADOOP_CONF_DIR
    
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

    # Create yarn-site.xml
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

# Initialize Spark log directory in HDFS
init_spark_logs() {
    # Create local spark-logs directory
    mkdir -p /spark-logs
    chmod 777 /spark-logs
}

# Start services based on mode
start_services() {
    case "$SPARK_MODE" in
        history)
            wait_for_hdfs
            init_spark_logs
            echo "Starting Spark History Server..."
            exec $SPARK_HOME/sbin/start-history-server.sh --properties-file $SPARK_HOME/conf/spark-defaults.conf
            # Keep container running
            tail -f $SPARK_HOME/logs/*
            ;;
        client)
            wait_for_hdfs
            wait_for_yarn
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

