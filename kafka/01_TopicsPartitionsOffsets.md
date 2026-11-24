# Apache Kafka — Key Concepts

## Table of Contents

1. [Kafka Topic](#kafka-topic)
2. [Partition](#partition)
3. [Offset](#offset)
4. [Data Stream](#data-stream)
5. [Immutability](#immutability)
6. [Data Retention](#data-retention)
7. [Kafka Producer](#kafka-producer)
8. [Kafka Consumer](#kafka-consumer)
9. [Message Assignment](#message-assignment)

[🏠 Main index](00_index.md)

---

## Kafka Topic
A named stream of data within a Kafka cluster. Similar to a database table but without
data constraints or querying capability. Topics support any message format (JSON, Avro,
binary, text, etc.). You can have as many topics as you want in a cluster.

[⬆️ Back to index](#table-of-contents)

## Partition
A subdivision of a topic. Each topic can have one or many partitions. Messages within
a partition are strictly ordered. Order is **not** guaranteed across partitions.

[⬆️ Back to index](#table-of-contents)

## Offset
An auto-incrementing integer ID assigned to each message within a partition, starting
at 0. Offsets are partition-specific — offset 3 in partition 0 is different from
offset 3 in partition 1. Offsets are never reused, even after messages are deleted.

[⬆️ Back to index](#table-of-contents)

## Data Stream
The sequence of messages flowing through a topic. This is why Kafka is called a
**data streaming platform**.

[⬆️ Back to index](#table-of-contents)

## Immutability
Once data is written to a partition it cannot be updated or deleted. New messages
can only be appended.

[⬆️ Back to index](#table-of-contents)

## Data Retention
By default, Kafka keeps messages for **one week**, after which they are deleted.
This period is configurable.

[⬆️ Back to index](#table-of-contents)

## Kafka Producer
A client that **writes/sends** data to a Kafka topic.

[⬆️ Back to index](#table-of-contents)

## Kafka Consumer
A client that **reads** data from a Kafka topic.

[⬆️ Back to index](#table-of-contents)

## Message Assignment
Without a key, messages are assigned to a **random partition**. Providing a key
allows control over which partition a message lands in.

[⬆️ Back to index](#table-of-contents)
