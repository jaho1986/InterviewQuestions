# Apache Kafka — Topic Replication

## Table of Contents

1. [Replication Factor](#replication-factor)
2. [Partition Replica](#partition-replica)
3. [Partition Leader](#partition-leader)
4. [ISR — In-Sync Replica](#isr--in-sync-replica)
5. [Replica Fetching (introduced in Kafka 2.4)](#replica-fetching-introduced-in-kafka-24)
6. [Fault Tolerance Summary](#fault-tolerance-summary)

[🏠 Main index](00_index.md)

---

## Replication Factor
The number of copies of each partition stored across different brokers.

- **Development:** replication factor of `1` (no redundancy).
- **Production:** replication factor of `2` or `3` (most commonly **3**).
- With a replication factor of `N`, you can lose `N - 1` brokers and still
  serve data normally.

[⬆️ Back to index](#table-of-contents)

## Partition Replica
A copy of a partition stored on a broker that is **not** the leader of that
partition. Replicas exist purely for fault tolerance — they replicate data from
the leader so they can take over if the leader goes down.

[⬆️ Back to index](#table-of-contents)

## Partition Leader
At any given time, **only one broker is the leader** for a partition.

- **Producers** can only write data to the **leader** broker of a partition.
- **Consumers** read by default only from the **leader** broker of a partition.
- If the leader broker goes down, a replica is elected as the new leader.

[⬆️ Back to index](#table-of-contents)

## ISR — In-Sync Replica
A replica that is **fully caught up** with the leader's data. If a replica falls
behind, it becomes an out-of-sync replica. ISRs are the candidates eligible to
become the new leader if the current leader fails.

[⬆️ Back to index](#table-of-contents)

## Replica Fetching *(introduced in Kafka 2.4)*
A feature that allows consumers to read from the **closest replica** instead of
always reading from the leader. Benefits:

- **Lower latency** when the consumer is physically closer to a replica than to
  the leader.
- **Reduced network cost** in cloud environments where reading within the same
  data center is cheaper than cross-region traffic.

[⬆️ Back to index](#table-of-contents)

## Fault Tolerance Summary

| Replication Factor | Brokers that can fail safely |
|---|---|
| 1 | 0 |
| 2 | 1 |
| 3 | 2 |

> **Key rule:** Always set a replication factor greater than 1 in production to
> ensure high availability.

[⬆️ Back to index](#table-of-contents)
