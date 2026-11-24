# Apache Kafka — Consumers

## Table of Contents

1. [Kafka Consumer](#kafka-consumer)
2. [Pull Model](#pull-model)
3. [Read Order](#read-order)
4. [Message Deserialization](#message-deserialization)
5. [Serializer / Deserializer Consistency](#serializer--deserializer-consistency)
6. [Changing Data Format](#changing-data-format)

[🏠 Main index](00_index.md)

---

## Kafka Consumer
A client responsible for **reading data from topic partitions**. Consumers
automatically know which broker (server) to read from, and can recover
automatically in case of broker failure.

[⬆️ Back to index](#table-of-contents)

## Pull Model
Consumers use a **pull model**: they actively *request* data from Kafka brokers.
The broker does NOT push data to consumers.

[⬆️ Back to index](#table-of-contents)

## Read Order
Data is always read **in order within a partition**, from the lowest to the
highest offset (0, 1, 2, 3...). There is **no ordering guarantee across
different partitions**.

[⬆️ Back to index](#table-of-contents)

## Message Deserialization
Kafka delivers messages as **bytes**. Deserialization is the process of
transforming those bytes back into usable objects in your programming language.

- The consumer must know **in advance** the expected format of the key and value.
- Each of key and value can have its **own deserializer**.
- Example: a byte key expected to be an integer uses an `IntegerDeserializer`;
  a byte value expected to be a string uses a `StringDeserializer`.

### Common built-in Deserializers
- `String` (including JSON)
- `Integer`, `Float`
- `Avro`, `Protobuf`

[⬆️ Back to index](#table-of-contents)

## Serializer / Deserializer Consistency
The serializer used by the **producer** and the deserializer used by the
**consumer** must always match for the same topic.

> ⚠️ **Never change the data type of a topic while it is in use.** Doing so
> will break consumers that expect the original format.

[⬆️ Back to index](#table-of-contents)

## Changing Data Format
If you need to change the data type of your messages, the correct approach is:

1. **Create a new topic** with the desired new format.
2. Reprogram your consumers to read from the new topic.

[⬆️ Back to index](#table-of-contents)
