# Checkpoint Questions - Answer Key

**For Instructor Use Only**

---

## Exercise 1: HDFS Basics

### Checkpoint Question 1
*Open the HDFS NameNode UI and find the transactions.csv file.*

**Expected Answers:**
- **Blocks:** 1 block (file is ~8MB, block size is 16MB, so fits in one block)
- **Block Size:** 16MB (configured in hadoop.env as 16777216 bytes)
- **DataNodes:** Blocks are stored on 2-3 DataNodes depending on replication factor

**Key Teaching Points:**
- Small files don't benefit from HDFS (single block = no parallelism)
- With larger datasets, you'd see multiple blocks distributed across nodes
- Replication factor determines how many copies exist

---

## Exercise 2: Spark Fundamentals

### Checkpoint Question 2
*How many jobs were triggered? Which operation triggered them?*

**Expected Answers:**
- **Jobs Triggered:** 1 job
- **Triggering Operation:** `collect()` - this is the ACTION that triggers execution
- `map()` and `filter()` are TRANSFORMATIONS - they only build the execution plan

**Key Teaching Points:**
- Lazy evaluation is a core Spark concept
- Nothing executes until an action is called
- This allows Spark to optimize the entire pipeline

---

## Exercise 3: Spark SQL

### Checkpoint Question 3
*What type of join was used?*

**Expected Answers:**
- **Join Type:** BroadcastHashJoin (most likely)
- **Why:** Products table is small (~500 rows, < 10MB)
  - Spark automatically broadcasts small tables to all executors
  - This avoids expensive shuffle join

**Alternative Answer (if forced large table):**
- SortMergeJoin for large-to-large table joins
- Requires shuffle to co-locate matching keys

**Key Teaching Points:**
- Broadcast join: small table replicated to all nodes
- Sort-merge join: both tables shuffled by join key
- Spark's Catalyst optimizer chooses automatically based on table sizes

---

## Exercise 4: Distributed Execution

### Checkpoint Question 4
*How many stages? What do shuffle metrics tell you?*

**Expected Answers:**
- **Stages:** 2 stages for a groupBy operation
  - Stage 1: Read data, compute partial aggregates per partition
  - Stage 2: Shuffle, combine partial results, produce final output
  
- **Shuffle Metrics:**
  - Shuffle Write: Data written at end of Stage 1 (partial aggregates)
  - Shuffle Read: Data read at start of Stage 2
  - Ideally shuffle size << input size (aggregation reduces data)

**Key Teaching Points:**
- Stage boundaries occur at shuffle points
- Minimize shuffles for performance (use broadcast joins, avoid wide transformations when possible)
- Watch for data skew in shuffle metrics (uneven partition sizes)

---

## Exercise 5: Break/Fix Challenge

### Checkpoint Question 5a (DataNode Failure)
**Expected Answers:**
- **Live DataNodes:** 2 (down from 3)
- **Under-replicated Blocks:** Yes, if replication factor > remaining DataNodes
- **File Readable:** YES - this is the key point!

**Why it still works:**
- Replication factor was 2 or 3
- Blocks have copies on other DataNodes
- NameNode routes reads to available replicas

### Checkpoint Question 5b (Spark Executor Failure)
**Expected Answers:**
- **Job Completed:** YES (eventually)
- **Tasks Retried:** Check the Tasks tab - failed tasks show in red, then retried
- **Recovery Mechanism:**
  - Spark detects lost executor
  - Scheduler re-runs failed tasks on remaining executors
  - RDD lineage allows recomputation if needed

**Key Teaching Points:**
- HDFS fault tolerance: replication
- Spark fault tolerance: RDD lineage + task retry
- Driver failure is different (would lose entire job)

---

## Summary Questions (Exercise 5)

1. **Why did HDFS work with one DataNode down?**
   - Block replication ensures multiple copies exist
   - NameNode knows all replica locations, routes to available copies

2. **What if replication=1 and that DataNode failed?**
   - Data would be LOST (or unavailable until DataNode returns)
   - This is why production uses replication factor ≥ 3

3. **How does Spark's RDD lineage help?**
   - Each RDD knows how it was created (its "lineage")
   - If a partition is lost, Spark can recompute it from parent RDDs
   - No need to checkpoint everything to disk

4. **Executor failure vs Driver failure?**
   - Executor: Tasks rescheduled, job continues
   - Driver: Entire application dies, must restart from scratch
   - In production, use checkpointing for critical jobs

