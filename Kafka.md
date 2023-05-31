# Apache Kafka

### Kafka Topics:
- Topics are a particulare stream of data within a Kafka Cluster. 
- They are like a table in a database (without all the constraints). 
- You can can have as many topics as you want in your Kafka Cluster.
- The way to identify a Kafka Topic is by its name.
- These Kafka topics support any kind of message format.
- The sequence of the messages is called a data stream.
- You cannot query topics, instead, we use Kafka PRoducers to send data and Kafka Consumers to read the data.
- Kafka Topics are immutable. That means that once the data is written into a partition, it cannot be changed.

### Partitions:
- Topics are split in partitions (example: 100 partitions).
- Messages within each partition are ordered.
- Each message with a partition gets an incremental Id and it's called offset. 
- Once the data is written to a partition, it cannot be changed (inmmutability).
- Data is kept only for a limited time (default is one week - configurable).
- Offset only have a meaning foar a specific partition.
  - E.g. offset 3 in partition 0 doesn't represent the same data as offset 3 in partition 1.
  - Offsets are not re-used even if previous messages have been deleted.
- Order is guaranteed only within a partition (not across partitions).
- Data is assigned randomly to a partition unless a key is provided.
