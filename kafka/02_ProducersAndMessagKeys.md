# Apache Kafka — Producers

## Table of Contents

1. [Kafka Producer](#kafka-producer)
2. [Message Key](#message-key)
3. [Kafka Message Structure](#kafka-message-structure)
4. [Message Serialization](#message-serialization)
5. [Kafka Partitioner](#kafka-partitioner)
6. [Load Balancing](#load-balancing)

[🏠 Main index](00_index.md)

---

## Kafka Producer
A client responsible for **writing data to topic partitions**. Producers know in
advance which partition and which broker (server) they will write to. In case of
broker failure, producers can automatically recover.

[⬆️ Back to index](#table-of-contents)

## Message Key
An optional field included in a Kafka message. It can be a string, number, binary,
etc. It controls which partition a message is sent to:

- **Key = null** → messages are sent **round-robin** across partitions (load balancing).
- **Key ≠ null** → all messages sharing the same key **always go to the same partition**
  (guaranteed by a hashing strategy).

Use a key when you need **ordered delivery for a specific entity**
(e.g., `truck_id` as key ensures all position updates for one truck arrive in order).

[⬆️ Back to index](#table-of-contents)

## Kafka Message Structure
A message created by a producer contains the following fields:

| Field | Description |
|---|---|
| **Key** | Optional. Binary format. Used for partition routing. |
| **Value** | The actual message content. Can be null but usually isn't. |
| **Compression** | Optional. Reduces message size. Options: `gzip`, `snappy`, `lz4`, `zstd`. |
| **Headers** | Optional. List of key-value pairs for metadata. |
| **Partition + Offset** | Target partition and its offset. |
| **Timestamp** | Set by the system or the user. |

[⬆️ Back to index](#table-of-contents)

## Message Serialization
Kafka only accepts **bytes** as input. Serialization is the process of transforming
objects (key and value) into bytes before sending them to Kafka.

- Each of key and value can have its **own serializer**.
- Example: an Integer key uses an `IntegerSerializer`; a String value uses a
  `StringSerializer`.

### Common built-in Serializers
- `String` (including JSON)
- `Integer`, `Float`
- `Avro`, `Protobuf`

[⬆️ Back to index](#table-of-contents)

## Kafka Partitioner
The internal logic that determines **which partition a message is assigned to**.
When a key is provided, the default partitioner hashes it using the
**murmur2 algorithm** to consistently map that key to the same partition.

> **Key takeaway:** It is the **producer** (not the Kafka broker) that decides
> which partition a message goes to.

[⬆️ Back to index](#table-of-contents)

## Load Balancing
When no key is provided, messages are distributed round-robin across all partitions,
spreading the write load evenly. This is one of the reasons Kafka scales well.

[⬆️ Back to index](#table-of-contents)
