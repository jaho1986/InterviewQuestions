# Apache Kafka — Key Concepts

## Kafka Topic
A named stream of data within a Kafka cluster. Similar to a database table but without
data constraints or querying capability. Topics support any message format (JSON, Avro,
binary, text, etc.). You can have as many topics as you want in a cluster.

## Partition
A subdivision of a topic. Each topic can have one or many partitions. Messages within
a partition are strictly ordered. Order is **not** guaranteed across partitions.

## Offset
An auto-incrementing integer ID assigned to each message within a partition, starting
at 0. Offsets are partition-specific — offset 3 in partition 0 is different from
offset 3 in partition 1. Offsets are never reused, even after messages are deleted.

## Data Stream
The sequence of messages flowing through a topic. This is why Kafka is called a
**data streaming platform**.

## Immutability
Once data is written to a partition it cannot be updated or deleted. New messages
can only be appended.

## Data Retention
By default, Kafka keeps messages for **one week**, after which they are deleted.
This period is configurable.

## Kafka Producer
A client that **writes/sends** data to a Kafka topic.

## Kafka Consumer
A client that **reads** data from a Kafka topic.

## Message Assignment
Without a key, messages are assigned to a **random partition**. Providing a key
allows control over which partition a message lands in.