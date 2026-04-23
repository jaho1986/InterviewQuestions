# Apache Kafka — Consumer Groups & Offsets

## Consumer Group
A named group of consumers that work together to read from a topic. Each consumer
within the group reads from **exclusive partitions**, so the group reads the topic
as a whole. Identified by the `group.id` property.

**Key rules:**
- One partition is assigned to **only one consumer** within the same group.
- If there are **more consumers than partitions**, the extra consumers stay
  **inactive** (on standby).
- You can have **multiple consumer groups on the same topic**, each reading
  independently (e.g., one group per service).

## Consumer Group — Partition Assignment Example

| Scenario | Result |
|---|---|
| 3 consumers, 5 partitions | Partitions are shared among consumers |
| 3 consumers, 3 partitions | Each consumer reads exactly 1 partition |
| 4 consumers, 3 partitions | 1 consumer stays inactive |
| 1 consumer, 3 partitions | That consumer reads all 3 partitions |

## Consumer Offsets
Kafka stores the offset at which each consumer group has been reading in an
internal topic called **`__consumer_offsets`**. This allows a consumer to resume
reading from where it left off after a crash or restart.

> Consumers should **periodically commit their offsets** after successfully
> processing messages.

## Delivery Semantics
Defines when offsets are committed and what happens if processing fails.

### At Least Once *(default for Java consumers)*
- Offsets are committed **after** the message is processed.
- If processing fails, the message is **read again** → possible duplicates.
- Requires **idempotent** processing (re-processing the same message must not
  cause side effects).

### At Most Once
- Offsets are committed **as soon as** messages are received.
- If processing fails, messages are **lost** and not re-read.

### Exactly Once
- Each message is processed **exactly one time**, no duplicates, no losses.
- For Kafka-to-Kafka workflows: use the **Transactional API** or
  **Kafka Streams API**.
- For Kafka-to-external-system workflows: use an **idempotent consumer**.

## Idempotent Processing
A processing logic where re-processing the same message multiple times produces
the same result without unintended side effects. Required when using
**At Least Once** delivery semantics to handle potential duplicate messages safely.