# HDFS & Hive Commands Cheat Sheet

## Table of Contents
- [HDFS Commands](#hdfs-commands)
- [Hive Commands](#hive-commands)
- [YARN Commands](#yarn-commands)
- [Common Workflows](#common-workflows)

---

## Connection Overview

### HDFS Connection
HDFS is accessed via the **Namenode container**. You need to use `docker exec` to run commands inside the container since HDFS client tools are installed there.

**Connection Methods:**
```bash
docker exec -it namenode bash
# Then run: hdfs dfs -ls /
```

### Hive Connection
Hive can be accessed via **JDBC connection string** or through the **Hive CLI** in the container.

**Connection Methods:**
```bash
# Method 1: JDBC Connection String (for tools like DBeaver, Python, Java)
jdbc:hive2://localhost:10000/default

# Method 2: Hive CLI in container
docker exec -it hive-server beeline -u "jdbc:hive2://localhost:10000/default"

# Method 3: Interactive Hive shell
docker exec -it hive-server hive

# Method 4: Python (using pyhive)
from pyhive import hive
conn = hive.connect(host='localhost', port=10000, database='default')
cursor = conn.cursor()
cursor.execute('SELECT * FROM table_name')
```

### YARN Connection
YARN is accessed via the **Resourcemanager container** for job submission and monitoring.

**Connection Methods:**
```bash
# Method 1: Direct command execution
docker exec -it resourcemanager yarn application -list

# Method 2: Interactive shell
docker exec -it resourcemanager bash

# Method 3: Web UI
http://localhost:8088  # YARN Resource Manager UI
```

---

## HDFS Commands

### Overview
HDFS (Hadoop Distributed File System) is the storage layer of Hadoop. It stores data across multiple nodes in a distributed manner. All HDFS commands must be run from within the Namenode container or from a host with HDFS client tools installed.

**Quick Start:**
```bash
# Enter the namenode container
docker exec -it namenode bash

# Now you can run HDFS commands
hdfs dfs -ls /
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -put /local/file.txt /user/hive/warehouse/
```

### File Operations

| Command | Explanation | Example |
|---------|-------------|---------|
| `hdfs dfs -ls <path>` | List files and directories | `hdfs dfs -ls /user/hive/warehouse` |
| `hdfs dfs -mkdir -p <path>` | Create directory (with parents) | `hdfs dfs -mkdir -p /data/input` |
| `hdfs dfs -put <local> <hdfs>` | Upload file from local to HDFS | `hdfs dfs -put /tmp/data.csv /data/input/` |
| `hdfs dfs -get <hdfs> <local>` | Download file from HDFS to local | `hdfs dfs -get /data/output/result.txt /tmp/` |
| `hdfs dfs -cat <file>` | Display file contents | `hdfs dfs -cat /data/input/data.csv` |
| `hdfs dfs -rm <file>` | Delete file | `hdfs dfs -rm /data/input/data.csv` |
| `hdfs dfs -rm -r <dir>` | Delete directory recursively | `hdfs dfs -rm -r /data/input` |
| `hdfs dfs -cp <src> <dest>` | Copy file/directory | `hdfs dfs -cp /data/input /data/backup` |
| `hdfs dfs -mv <src> <dest>` | Move file/directory | `hdfs dfs -mv /data/input /data/archive` |
| `hdfs dfs -du -h <path>` | Show disk usage (human readable) | `hdfs dfs -du -h /data` |
| `hdfs dfs -count <path>` | Count files and directories | `hdfs dfs -count /data` |
| `hdfs dfs -chmod <perms> <path>` | Change permissions | `hdfs dfs -chmod 755 /data` |
| `hdfs dfs -chown <user>:<group> <path>` | Change owner | `hdfs dfs -chown hive:hadoop /data` |

### Cluster Information

| Command | Explanation | Example |
|---------|-------------|---------|
| `hdfs dfsadmin -report` | Show cluster status and node info | `hdfs dfsadmin -report` |
| `hdfs dfsadmin -safemode leave` | Exit safe mode | `hdfs dfsadmin -safemode leave` |
| `hdfs fsck /` | Check file system health | `hdfs fsck / -files -blocks` |
| `hdfs namenode -format` | Format namenode (CAUTION!) | `hdfs namenode -format` |

---

## Hive Commands

### Overview
Hive is a data warehouse system that provides SQL-like query language (HiveQL) on top of Hadoop. It translates SQL queries into MapReduce jobs. You can connect to Hive using JDBC, Beeline CLI, or the interactive Hive shell.

**Quick Start:**
```bash
# Method 1: Using Beeline (recommended)
docker exec -it hive-server beeline -u "jdbc:hive2://localhost:10000/default" -n hive

# Method 2: Interactive Hive shell
docker exec -it hive-server hive

# Method 3: Single query execution
docker exec -it hive-server hive -e "SHOW DATABASES;"

# Method 4: From file
docker exec -it hive-server hive -f /path/to/query.sql
```

**JDBC Connection String (for external tools):**
```
jdbc:hive2://localhost:10000/default
Username: hive
Password: (usually empty or hive)
```

### Database & Table Operations

| Command | Explanation | Example |
|---------|-------------|---------|
| `CREATE DATABASE <name>` | Create a new database | `CREATE DATABASE my_db;` |
| `DROP DATABASE <name>` | Delete database | `DROP DATABASE my_db;` |
| `DROP DATABASE <name> CASCADE` | Delete database with tables | `DROP DATABASE my_db CASCADE;` |
| `SHOW DATABASES` | List all databases | `SHOW DATABASES;` |
| `USE <database>` | Switch to database | `USE my_db;` |
| `CREATE TABLE <name> (...)` | Create table | `CREATE TABLE users (id INT, name STRING);` |
| `DROP TABLE <name>` | Delete table | `DROP TABLE users;` |
| `SHOW TABLES` | List tables in current DB | `SHOW TABLES;` |
| `DESCRIBE <table>` | Show table schema | `DESCRIBE users;` |
| `DESCRIBE FORMATTED <table>` | Show detailed table info | `DESCRIBE FORMATTED users;` |

### Data Operations

| Command | Explanation | Example |
|---------|-------------|---------|
| `INSERT INTO <table> VALUES (...)` | Insert data | `INSERT INTO users VALUES (1, 'John');` |
| `INSERT OVERWRITE <table> SELECT ...` | Replace table data | `INSERT OVERWRITE users SELECT * FROM temp_users;` |
| `SELECT * FROM <table>` | Query table | `SELECT * FROM users LIMIT 10;` |
| `SELECT COUNT(*) FROM <table>` | Count rows | `SELECT COUNT(*) FROM users;` |
| `ALTER TABLE <table> ADD COLUMNS (...)` | Add columns | `ALTER TABLE users ADD COLUMNS (age INT);` |
| `ALTER TABLE <table> RENAME TO <new>` | Rename table | `ALTER TABLE users RENAME TO customers;` |
| `TRUNCATE TABLE <table>` | Delete all rows | `TRUNCATE TABLE users;` |

### Partitioning & Bucketing

| Command | Explanation | Example |
|---------|-------------|---------|
| `CREATE TABLE ... PARTITIONED BY (...)` | Create partitioned table | `CREATE TABLE sales (id INT) PARTITIONED BY (year INT);` |
| `ALTER TABLE <table> ADD PARTITION (...)` | Add partition | `ALTER TABLE sales ADD PARTITION (year=2024);` |
| `SHOW PARTITIONS <table>` | List partitions | `SHOW PARTITIONS sales;` |
| `ALTER TABLE <table> DROP PARTITION (...)` | Remove partition | `ALTER TABLE sales DROP PARTITION (year=2023);` |

---

## YARN Commands

### Overview
YARN (Yet Another Resource Negotiator) is the resource management and job scheduling layer of Hadoop. It manages cluster resources and schedules jobs across the cluster. All YARN commands must be run from the Resourcemanager container.

**Quick Start:**
```bash
# Enter the resourcemanager container
docker exec -it resourcemanager bash

# View running applications
yarn application -list

# View application status
yarn application -status <application_id>

# Kill an application
yarn application -kill <application_id>
```

**Web UI:**
- **YARN Resource Manager:** http://localhost:8088
- **Application History:** http://localhost:19888

### Job Management

| Command | Explanation | Example |
|---------|-------------|---------|
| `yarn application -list` | List all applications | `yarn application -list` |
| `yarn application -list -appStates RUNNING` | List running applications | `yarn application -list -appStates RUNNING` |
| `yarn application -list -appStates FINISHED` | List finished applications | `yarn application -list -appStates FINISHED` |
| `yarn application -status <app_id>` | Show application status | `yarn application -status application_1234567890123_0001` |
| `yarn application -kill <app_id>` | Kill an application | `yarn application -kill application_1234567890123_0001` |
| `yarn logs -applicationId <app_id>` | View application logs | `yarn logs -applicationId application_1234567890123_0001` |
| `yarn logs -applicationId <app_id> -appOwner <user>` | View logs for specific user | `yarn logs -applicationId application_1234567890123_0001 -appOwner hive` |

### Cluster Information

| Command | Explanation | Example |
|---------|-------------|---------|
| `yarn node -list` | List all nodes in cluster | `yarn node -list` |
| `yarn node -list -states RUNNING` | List running nodes | `yarn node -list -states RUNNING` |
| `yarn node -status <node_id>` | Show node status | `yarn node -status node1.example.com:8042` |
| `yarn queue -list` | List all queues | `yarn queue -list` |
| `yarn top` | Show real-time cluster metrics | `yarn top` |
| `yarn daemonlog -getLevel <host:port> <logger>` | Get logger level | `yarn daemonlog -getLevel localhost:8042 org.apache.hadoop` |

### Queue Management

| Command | Explanation | Example |
|---------|-------------|---------|
| `yarn queue -list` | List all queues | `yarn queue -list` |
| `yarn queue -status <queue_name>` | Show queue status | `yarn queue -status default` |
| `yarn rmadmin -refreshQueues` | Reload queue configuration | `yarn rmadmin -refreshQueues` |

---

## Common Workflows

### Workflow 1: Upload CSV to HDFS and Create Hive Table

**Step 1: Upload file to HDFS**
```bash
# Enter namenode container
docker exec -it namenode bash

# Create directory
hdfs dfs -mkdir -p /data/raw

# Upload CSV file (assuming file is in container or use docker cp first)
hdfs dfs -put /tmp/data.csv /data/raw/

# Verify upload
hdfs dfs -ls -h /data/raw/
```

**Step 2: Create Hive table pointing to HDFS location**
```bash
# Enter hive-server container
docker exec -it hive-server beeline -u "jdbc:hive2://localhost:10000/default" -n hive

# Run this query:
CREATE TABLE raw_data (
    id INT,
    name STRING,
    age INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/data/raw';

# Verify table
SHOW TABLES;
DESCRIBE raw_data;
```

**Step 3: Query the data**
```bash
# Still in Beeline
SELECT * FROM raw_data LIMIT 5;
SELECT COUNT(*) FROM raw_data;
```

### Workflow 2: Running Hive Queries from File

**Create query file locally:**
```sql
-- query.sql
USE default;

CREATE TABLE IF NOT EXISTS users (
    user_id INT,
    username STRING,
    email STRING,
    created_date STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';

INSERT INTO users VALUES (1, 'john_doe', 'john@example.com', '2024-01-15');
INSERT INTO users VALUES (2, 'jane_smith', 'jane@example.com', '2024-01-16');

SELECT * FROM users;
```

**Execute the file:**
```bash
# Copy file to container
docker cp query.sql hive-server:/tmp/

# Run the query file
docker exec -it hive-server hive -f /tmp/query.sql
```

### Workflow 3: Monitor Hive Job Execution with YARN

**Step 1: Submit a Hive query**
```bash
# Enter hive-server
docker exec -it hive-server beeline -u "jdbc:hive2://localhost:10000/default" -n hive

# Run a query that will create a YARN job
SELECT COUNT(*) FROM large_table;
```

**Step 2: Monitor in YARN (in another terminal)**
```bash
# Enter resourcemanager
docker exec -it resourcemanager bash

# List running applications
yarn application -list -appStates RUNNING

# Get details of a specific application
yarn application -status application_1234567890123_0001

# View application logs
yarn logs -applicationId application_1234567890123_0001
```

**Step 3: Check YARN Web UI**
```
Open browser: http://localhost:8088
- View running applications
- Check resource usage
- Monitor job progress
```

### Workflow 4: Check HDFS Cluster Health

```bash
# Enter namenode
docker exec -it namenode bash

# Check cluster status
hdfs dfsadmin -report

# Check file system health
hdfs fsck / -files -blocks

# Check disk usage
hdfs dfs -du -h /

# List all files in warehouse
hdfs dfs -ls -R /user/hive/warehouse
```

### Workflow 5: Connect from External Tools (DBeaver, Python, etc.)

**DBeaver Connection:**
1. New Database Connection → Hive
2. Server Host: `localhost`
3. Port: `10000`
4. Database: `default`
5. Username: `hive`
6. Test Connection

**Python Connection:**
```python
from pyhive import hive

# Connect to Hive
conn = hive.connect(
    host='localhost',
    port=10000,
    database='default',
    username='hive'
)

cursor = conn.cursor()

# Execute query
cursor.execute('SELECT * FROM users LIMIT 5')

# Fetch results
results = cursor.fetchall()
for row in results:
    print(row)

cursor.close()
conn.close()
```

**Java Connection:**
```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class HiveConnection {
    public static void main(String[] args) throws Exception {
        Class.forName("org.apache.hive.jdbc.HiveDriver");

        Connection conn = DriverManager.getConnection(
            "jdbc:hive2://localhost:10000/default",
            "hive",
            ""
        );

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM users LIMIT 5");

        while (rs.next()) {
            System.out.println(rs.getInt(1) + " " + rs.getString(2));
        }

        rs.close();
        stmt.close();
        conn.close();
    }
}
```

---

## Tips & Best Practices

### HDFS Tips
- **Always check available space** before uploading large files: `hdfs dfs -du -h /`
- **Use replication factor wisely** - default is 3, reduce for test data: `hdfs dfs -setrep -w 1 /path`
- **Monitor namenode memory** - it stores all file metadata in RAM
- **Use `-R` flag** for recursive operations: `hdfs dfs -ls -R /`
- **Backup important data** - HDFS is distributed but not a backup system

### Hive Tips
- **Always use `DESCRIBE FORMATTED`** to check table location and properties
- **Partition large tables** to improve query performance and reduce scan time
- **Use `LIMIT`** when testing queries to avoid processing entire datasets
- **Use `CASCADE`** carefully when dropping databases with tables
- **Set `hive.exec.parallel=true`** for parallel query execution
- **Use external tables** for data not managed by Hive: `CREATE EXTERNAL TABLE ...`
- **Check table statistics** before joins: `ANALYZE TABLE table_name COMPUTE STATISTICS;`
- **Use Beeline instead of Hive CLI** - Hive CLI is deprecated

### YARN Tips
- **Monitor queue capacity** - ensure jobs don't exceed allocated resources
- **Check application logs** when jobs fail: `yarn logs -applicationId <app_id>`
- **Use `yarn top`** for real-time cluster monitoring
- **Set memory limits** to prevent out-of-memory errors: `mapreduce.map.memory.mb`
- **Kill stuck applications** with: `yarn application -kill <app_id>`
- **Check node health** regularly: `yarn node -list -states RUNNING`

### General Tips
- **Use Docker containers** for isolated environments - enter with `docker exec -it <container> bash`
- **Copy files to containers** before processing: `docker cp local_file container:/path/`
- **Check container logs** for debugging: `docker-compose logs <service> --tail=50`
- **Use meaningful table names** and add comments: `COMMENT 'Description of table'`
- **Version control your SQL scripts** - store them in git
- **Test queries on small datasets first** before running on production data

