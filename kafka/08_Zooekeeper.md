# Apache Kafka — Zookeeper

## Zookeeper
A companion software that historically managed Kafka brokers. It is slowly being
phased out of the Kafka ecosystem.

### Responsibilities of Zookeeper
- Maintains a **list of all Kafka brokers** in the cluster.
- Performs **leader elections** for partitions when a broker goes down.
- Sends **notifications** to brokers on cluster changes such as new topics,
  broker failures, broker restarts, and topic deletions.
- Holds **Kafka cluster metadata**.

## Zookeeper Architecture
- Operates with an **odd number of servers**: 1, 3, 5, or 7 (never more than 7).
- Has its own **leader/follower** model:
  - **Leader** → handles writes.
  - **Followers** → handle reads.

## Zookeeper & Kafka Version Timeline

| Kafka Version | Zookeeper Status |
|---|---|
| Up to 2.x | **Required** — Kafka cannot run without Zookeeper |
| 3.x | **Optional** — Kafka can run without Zookeeper via KRaft |
| 4.x | **Removed** — Zookeeper is no longer supported |

## KRaft (Kafka Raft)
The mechanism introduced in Kafka 3.x that allows Kafka to manage its own
metadata **without Zookeeper**. It replaces Zookeeper's role in leader election
and metadata management. See KIP-500 for details.

## Consumer Offsets & Zookeeper
In very old Kafka versions, consumer offsets were stored in Zookeeper.
Since **Kafka 0.10**, consumer offsets are stored in the internal Kafka topic
**`__consumer_offsets`**. Zookeeper holds **no consumer data**.

## Kafka Clients & Zookeeper
Modern Kafka clients (producers, consumers, admin tools) connect **only to
Kafka brokers**, not to Zookeeper. This migration has been completed across
all CLI tools and client APIs.

> ⚠️ **Best practice:** Never use Zookeeper as a connection endpoint in your
> Kafka client code or configuration. Always connect to Kafka brokers directly.

## Why Zookeeper Is Being Removed
- Zookeeper is **less secure** than Kafka.
- Having a separate system adds operational complexity.
- Removing it simplifies the architecture and improves security.