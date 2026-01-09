#!/bin/bash
set -e

# Configure Hadoop from environment variables
configure_hadoop() {
    local file=$1
    local prefix=$2
    
    # Convert environment variables to XML properties
    printenv | grep "^${prefix}" | while IFS='=' read -r name value; do
        # Remove prefix and convert ___ to - and _ to .
        prop_name=$(echo "${name#${prefix}}" | sed 's/___/-/g' | sed 's/_/./g' | tr '[:upper:]' '[:lower:]')
        
        # Add property to config file
        if ! grep -q "<name>$prop_name</name>" "$file"; then
            sed -i "/<\/configuration>/i\\
    <property>\\
        <name>$prop_name</name>\\
        <value>$value</value>\\
    </property>" "$file"
        fi
    done
}

# Initialize configuration files
init_config() {
    for file in core-site.xml hdfs-site.xml yarn-site.xml mapred-site.xml; do
        if [ ! -f "$HADOOP_CONF_DIR/$file" ] || [ ! -s "$HADOOP_CONF_DIR/$file" ]; then
            echo '<?xml version="1.0" encoding="UTF-8"?>' > "$HADOOP_CONF_DIR/$file"
            echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> "$HADOOP_CONF_DIR/$file"
            echo '<configuration>' >> "$HADOOP_CONF_DIR/$file"
            echo '</configuration>' >> "$HADOOP_CONF_DIR/$file"
        fi
    done
    
    configure_hadoop "$HADOOP_CONF_DIR/core-site.xml" "CORE_CONF_"
    configure_hadoop "$HADOOP_CONF_DIR/hdfs-site.xml" "HDFS_CONF_"
    configure_hadoop "$HADOOP_CONF_DIR/yarn-site.xml" "YARN_CONF_"
    configure_hadoop "$HADOOP_CONF_DIR/mapred-site.xml" "MAPRED_CONF_"
}

# Wait for namenode to be ready
wait_for_namenode() {
    echo "Waiting for NameNode to be ready..."
    while ! nc -z namenode 9000; do
        sleep 2
    done
    echo "NameNode is ready!"
}

# Start services based on node type
start_services() {
    case "$HADOOP_NODE_TYPE" in
        namenode)
            echo "Starting NameNode..."
            if [ ! -d "/hadoop/dfs/name/current" ]; then
                echo "Formatting NameNode..."
                hdfs namenode -format -force -nonInteractive
            fi
            exec hdfs namenode
            ;;
        datanode)
            wait_for_namenode
            echo "Starting DataNode..."
            exec hdfs datanode
            ;;
        resourcemanager)
            wait_for_namenode
            echo "Starting ResourceManager..."
            exec yarn resourcemanager
            ;;
        nodemanager)
            echo "Waiting for ResourceManager..."
            while ! nc -z resourcemanager 8032; do
                sleep 2
            done
            echo "Starting NodeManager..."
            exec yarn nodemanager
            ;;
        *)
            echo "Unknown node type: $HADOOP_NODE_TYPE"
            exit 1
            ;;
    esac
}

# Main
init_config
start_services

