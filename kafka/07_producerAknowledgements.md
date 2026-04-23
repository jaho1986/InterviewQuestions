# Apache Kafka — Producer Acknowledgements & Topic Durability

## Producer Acknowledgements (acks)
A setting that controls whether the producer waits for confirmation
from the broker that a write was successful. There are three options:

| Setting | Behavior | Data Loss Risk |
|---|---|---|
| `acks=0` | Producer does **not** wait for any acknowledgement | High — if a broker goes down, the producer won't know |
| `acks=1` | Producer waits for the **leader** broker to acknowledge | Limited — leader confirms, but replicas may not have the data yet |
| `acks=all` | Producer waits for the **leader + all ISRs** to acknowledge | None — under normal circumstances, guarantees no data loss |

## Topic Durability
The ability of a Kafka topic to withstand broker failures without losing data.
Determined by the **replication factor**.

> **Rule:** With a replication factor of `N`, you can permanently lose up to
> `N - 1` brokers and still have a copy of your data available in the cluster.

### Examples

| Replication Factor | Brokers that can be lost safely |
|---|---|
| 2 | 1 |
| 3 | 2 |

## Relationship Between acks and Durability
Using `acks=all` combined with a high replication factor provides the strongest
durability guarantee, as every in-sync replica must confirm the write before
the producer considers it successful.