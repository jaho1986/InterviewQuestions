# Apache Kafka — Brokers

## Kafka Broker
A server within a Kafka cluster. Brokers are identified by an **integer ID**
(e.g., 101, 102, 103). Each broker stores only a subset of the topic partitions,
not all the data in the cluster.

## Kafka Cluster
An ensemble of multiple Kafka brokers working together. A typical starting point
is **3 brokers**, but large clusters can have over 100.

## Data Distribution
Topic partitions are **spread across all brokers** in no particular order. This
means:
- No single broker holds all the data.
- Multiple topics and their partitions coexist across different brokers.
- Broker 103 may hold Topic-A Partition 1 but have no partitions of Topic-B —
  that is completely normal.

> This distribution is what enables Kafka's **horizontal scaling**: the more
> brokers and partitions you add, the more the data spreads across the cluster.

## Horizontal Scaling
Kafka scales by adding more brokers and partitions. Each new broker takes on a
share of the partitions, distributing both storage and load across the cluster.

## Bootstrap Server
Every broker in a Kafka cluster acts as a **bootstrap server**. A client only
needs to connect to **one broker** to discover the entire cluster.

## Broker Discovery Mechanism
The process by which Kafka clients automatically learn about all brokers in the
cluster:

1. The client connects to any broker (the bootstrap server) and sends a
   **metadata request**.
2. That broker responds with a list of **all brokers** in the cluster, plus
   information about which broker holds which partition.
3. The client then connects directly to the broker(s) it needs to produce or
   consume data.

> Each broker stores **full metadata** about the entire cluster (all brokers,
> topics, and partitions), which is what makes this discovery possible.