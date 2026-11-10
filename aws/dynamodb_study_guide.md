# DynamoDB Study Guide

Topics are ordered from **easiest to most complex**.

## Table of Contents

1. [What is DynamoDB?](#1-what-is-dynamodb)
2. [SQL vs NoSQL](#2-sql-vs-nosql)
3. [Aurora vs DynamoDB](#3-aurora-vs-dynamodb)
4. [When to use DynamoDB](#4-when-to-use-dynamodb)
5. [Tables, Items and Attributes](#5-tables-items-and-attributes)
6. [Data Types](#6-data-types)
7. [Primary Key: Simple and Composite](#7-primary-key-simple-and-composite)
8. [Eventual Consistency vs Strong Consistency](#8-eventual-consistency-vs-strong-consistency)
9. [Load, Save, Query and Delete](#9-load-save-query-and-delete)
10. [Query vs Scan](#10-query-vs-scan)
11. [Filter Expression](#11-filter-expression)
12. [Cardinality and Data Distribution](#12-cardinality-and-data-distribution)
13. [How to Choose the Right Key](#13-how-to-choose-the-right-key)
14. [Access Patterns](#14-access-patterns)
15. [Denormalization](#15-denormalization)
16. [Considerations When Creating Tables](#16-considerations-when-creating-tables)
17. [Secondary Indexes: GSI and LSI](#17-secondary-indexes-gsi-and-lsi)
18. [Locks](#18-locks)
19. [Autoscaling](#19-autoscaling)
20. [DynamoDB Streams](#20-dynamodb-streams)
21. [Transactions](#21-transactions)
22. [Global Tables](#22-global-tables)
23. [Column and Row Level Permissions](#23-column-and-row-level-permissions)
24. [Quick Review Cheat Sheet](#24-quick-review-cheat-sheet)

---

## 1. What is DynamoDB?

**Amazon DynamoDB** is a fully managed database service from AWS.

- **Type:** NoSQL database. It is **key-value** and **document** based.
- **Serverless:** you do not manage servers, patches or updates.
- **Fast:** single-digit millisecond response time at any scale.
- **Scalable:** it grows automatically with your traffic.
- **Highly available:** data is copied across 3 Availability Zones.

> 💡 Think of it as a very big, very fast table where you find data by its **key**.

---

## 2. SQL vs NoSQL

| Feature | SQL (Relational) | NoSQL |
|---|---|---|
| Structure | Tables with fixed **schema** | Flexible schema |
| Relationships | **JOINs** between tables | Usually no JOINs |
| Query language | SQL | Depends on the database (APIs) |
| Scaling | Mostly **vertical** (bigger server) | Mostly **horizontal** (more servers) |
| Data design | Normalized (no repeated data) | Denormalized (repeated data is OK) |
| Best for | Complex queries, reports | Speed, scale, simple access by key |
| Examples | MySQL, PostgreSQL, Aurora | DynamoDB, MongoDB, Redis |

**Key idea:** in SQL you design tables first, then write any query you want. In NoSQL (DynamoDB) you design for your **queries first**.

---

## 3. Aurora vs DynamoDB

| Feature | Amazon Aurora | Amazon DynamoDB |
|---|---|---|
| Type | Relational (SQL) | NoSQL (key-value / document) |
| Compatible with | MySQL, PostgreSQL | Its own API |
| Schema | Fixed | Flexible (only the key is required) |
| JOINs | Yes | No |
| Flexible queries | Yes (any column) | Limited (by key and indexes) |
| Scaling | Storage grows automatically; compute needs instances | Fully automatic |
| Serverless | Aurora Serverless (optional) | Always serverless |
| Latency | Milliseconds | Single-digit milliseconds |
| Max item/row size | Large (depends on engine) | **400 KB per item** |
| Best for | Apps with complex relationships and reports | High traffic, simple access patterns |

**Simple rule:** need JOINs and ad-hoc queries? → **Aurora**. Need huge scale and fast lookups by key? → **DynamoDB**.

---

## 4. When to use DynamoDB

✅ **Good fit**

- Shopping carts, user sessions, user profiles
- Gaming leaderboards and player data
- IoT and time-series data
- Serverless apps (works great with AWS Lambda)
- Applications with **known access patterns**
- Need for very high traffic and low latency

❌ **Not a good fit**

- Complex queries with many JOINs
- Ad-hoc analytics and reports (use Athena, Redshift or Aurora)
- Data that changes its query needs all the time
- Items larger than 400 KB (store files in S3, save the link in DynamoDB)

---

## 5. Tables, Items and Attributes

| DynamoDB | SQL equivalent | Meaning |
|---|---|---|
| **Table** | Table | A collection of data |
| **Item** | Row | One record in the table |
| **Attribute** | Column | One piece of data in an item |

Example item:

```json
{
  "UserId": "u-100",
  "Name": "Ana",
  "Age": 30,
  "Hobbies": ["music", "chess"]
}
```

Important points:

- Items in the same table **can have different attributes** (no fixed schema).
- Only the **primary key** attributes are required.
- Maximum item size: **400 KB**.

---

## 6. Data Types

### Scalar types (one value)

| Code | Type | Example |
|---|---|---|
| `S` | String | `"Ana"` |
| `N` | Number | `42` |
| `B` | Binary | Image bytes |
| `BOOL` | Boolean | `true` |
| `NULL` | Null | `null` |

### Set types (unique values, same type, no order)

| Code | Type |
|---|---|
| `SS` | String Set |
| `NS` | Number Set |
| `BS` | Binary Set |

### Document types (nested)

| Code | Type | Example |
|---|---|---|
| `L` | List (ordered) | `["a", 1, true]` |
| `M` | Map (key-value) | `{"city": "Toluca"}` |

> 📌 Primary key attributes can only be **String, Number or Binary**.

---

## 7. Primary Key: Simple and Composite

Every table **must** have a primary key. It makes each item unique.

### Simple primary key (Partition Key only)

A simple primary key uses only one attribute, called the **Partition Key (PK)**, to identify each item in the table. Because it is the only key, each PK value must be **unique**, so no two items can have the same value.

| UserId (PK) | Name |
|---|---|
| u-1 | Ana |
| u-2 | Luis |

### Composite primary key (Partition Key + Sort Key)

A composite primary key uses two attributes: a **Partition Key (PK)** and a **Sort Key (SK)**. Many items can share the same PK, but the **PK + SK pair must be unique**, and items with the same PK are stored together and **sorted by SK**.

| CustomerId (PK) | OrderDate (SK) | Total |
|---|---|---|
| c-1 | 2026-01-05 | 50 |
| c-1 | 2026-02-10 | 80 |
| c-2 | 2026-01-20 | 30 |

### What is the Partition Key?

DynamoDB passes the PK through a **hash function**. The result decides **which physical partition** stores the item. A good PK spreads data evenly.

### What does the Sort Key allow?

- Sort data inside a partition.
- Use conditions: `=`, `<`, `>`, `BETWEEN`, `begins_with`.

---

## 8. Eventual Consistency vs Strong Consistency

DynamoDB copies data to several places. A read can be:

| | Eventually Consistent (default) | Strongly Consistent |
|---|---|---|
| Returns the latest write? | **Maybe not** (usually in less than 1 second) | **Always** |
| Cost | Cheaper (half the cost) | More expensive |
| Latency | Lower | Slightly higher |
| Available on GSI? | Yes | **No** (only eventual) |
| Available on Global Tables? | Yes | Only in the same Region as the write |

```python
# Strongly consistent read
table.get_item(Key={"UserId": "u-1"}, ConsistentRead=True)
```

There is a third option: **transactional reads** (see [Transactions](#21-transactions)).

### Capacity units (to understand cost)

- **1 RCU** = one strongly consistent read per second, up to **4 KB**. (Eventually consistent: 2 reads per RCU.)
- **1 WCU** = one write per second, up to **1 KB**.

---

## 9. Load, Save, Query and Delete

Examples with Python and `boto3`.

```python
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("Orders")
```

### Save (create or replace): `put_item`

```python
table.put_item(Item={
    "CustomerId": "c-1",
    "OrderDate": "2026-03-01",
    "Total": 100
})
```

> ⚠️ `put_item` **replaces** the whole item if the key already exists.

### Load (read one item): `get_item`

```python
response = table.get_item(Key={"CustomerId": "c-1", "OrderDate": "2026-03-01"})
item = response.get("Item")
```

### Update (change some attributes): `update_item`

```python
table.update_item(
    Key={"CustomerId": "c-1", "OrderDate": "2026-03-01"},
    UpdateExpression="SET Total = :t",
    ExpressionAttributeValues={":t": 120}
)
```

### Query (read many items with the same PK): `query`

```python
response = table.query(
    KeyConditionExpression=Key("CustomerId").eq("c-1") &
                           Key("OrderDate").begins_with("2026-")
)
items = response["Items"]
```

### Delete: `delete_item`

```python
table.delete_item(Key={"CustomerId": "c-1", "OrderDate": "2026-03-01"})
```

### Batch operations

- `batch_write_item`: up to **25** puts/deletes.
- `batch_get_item`: up to **100** items.

---

## 10. Query vs Scan

| | **Query** | **Scan** |
|---|---|---|
| What it does | Finds items by **partition key** (and optional sort key condition) | Reads **every item** in the table |
| Speed | Fast | Slow on big tables |
| Cost | Low (reads only what it needs) | High (reads the full table) |
| Needs the key? | **Yes** | No |
| Works on | Table, GSI, LSI | Table, GSI, LSI |
| Production use | ✅ Recommended | ⚠️ Avoid (use for small tables or one-time jobs) |

```python
# Query: fast, uses the key
table.query(KeyConditionExpression=Key("CustomerId").eq("c-1"))

# Scan: reads everything
table.scan()
```

Important notes:

- Both return a maximum of **1 MB per call**. Use `LastEvaluatedKey` to get the next page.
- Scan can be made faster with **parallel scan** (more cost).

---

## 11. Filter Expression

A **filter expression** removes items from the result **after** they are read.

```python
from boto3.dynamodb.conditions import Attr

table.query(
    KeyConditionExpression=Key("CustomerId").eq("c-1"),
    FilterExpression=Attr("Total").gt(50)
)
```

Key points:

- Works with `query` and `scan`.
- ❗ It **does not reduce the cost**. DynamoDB reads all matching items first, then filters. You pay for all of them.
- The 1 MB limit applies **before** filtering.
- You **cannot** filter on the partition key or sort key (use `KeyConditionExpression` for that).

| | KeyConditionExpression | FilterExpression |
|---|---|---|
| Uses | PK and SK | Any other attribute |
| Applied | **Before** reading | **After** reading |
| Reduces cost | ✅ Yes | ❌ No |

---

## 12. Cardinality and Data Distribution

**Cardinality** = how many **different values** an attribute has.

- **High cardinality:** many unique values (e.g., `UserId`, `OrderId`). ✅ Good for a partition key.
- **Low cardinality:** few unique values (e.g., `Gender`, `Status`, `Country`). ❌ Bad for a partition key.

### Why does it matter?

DynamoDB splits data into **partitions**. Each partition has limits (about **3,000 RCU** and **1,000 WCU** per second).

- Good distribution → traffic is spread evenly across partitions.
- Bad distribution → a **hot partition** (one partition gets too much traffic) and you get **throttling** errors.

```
Bad PK  (Status):    [ACTIVE ████████████] [CLOSED █] [PENDING █]   ← hot partition
Good PK (UserId):    [██] [██] [██] [██] [██] [██]                  ← even load
```

### How to fix hot keys

- Choose a high-cardinality key.
- Add a random or calculated suffix (**write sharding**), e.g., `2026-03-01#3`.
- Use caching (DAX) for very popular reads.

---

## 13. How to Choose the Right Key

Follow these steps:

1. **List your access patterns** (how will the app read and write data?).
2. Pick a **partition key** with **high cardinality** that you always know when you read.
3. Make sure traffic is spread **evenly** across key values.
4. Add a **sort key** if you need to:
   - get many related items together,
   - sort data (by date, version, status),
   - filter with ranges (`BETWEEN`, `begins_with`).
5. Test: *"Can I answer my main queries using only the key?"* If not, add an index.

| Use case | Partition Key | Sort Key |
|---|---|---|
| User profile | `UserId` | — |
| Orders by customer | `CustomerId` | `OrderDate` |
| Chat messages | `ChatRoomId` | `Timestamp` |
| IoT sensor data | `DeviceId` | `Timestamp` |
| Game scores | `GameId` | `UserId` |

❌ Avoid: `Status`, `Date` (alone), `Boolean` fields, or any key with few values.

---

## 14. Access Patterns

An **access pattern** is a question your application asks the database.

Examples:

- "Get a user by ID."
- "Get all orders of a customer, newest first."
- "Get all orders with status `SHIPPED`."

### Design process for DynamoDB

1. **List** all access patterns **before** creating the table.
2. Note how often each one runs and how fast it must be.
3. Design keys and indexes to satisfy each pattern.
4. Use **one table** or few tables (single-table design) when it makes sense.

| # | Access pattern | Solution |
|---|---|---|
| 1 | Get user by ID | `GetItem` on PK = `UserId` |
| 2 | Get orders by customer | `Query` on PK = `CustomerId` |
| 3 | Get orders by status | `Query` on a **GSI** with PK = `Status` |

> 🔑 In SQL: *data first, queries later*. In DynamoDB: ***queries first, data model later***.

---

## 15. Denormalization

**Normalization** (SQL): split data into many tables to avoid repetition.
**Denormalization** (DynamoDB): store **related data together**, even if it repeats.

### Why?

- DynamoDB has **no JOINs**.
- One read gets all the data you need → faster and cheaper.
- Storage is cheap; reads are expensive.

### Example

SQL (normalized): 2 tables + JOIN.

```
Orders(OrderId, CustomerId)   Customers(CustomerId, Name)
```

DynamoDB (denormalized): one item with everything.

```json
{
  "OrderId": "o-1",
  "CustomerId": "c-1",
  "CustomerName": "Ana",
  "Items": [{"Product": "Book", "Qty": 2}]
}
```

### Trade-offs

| ✅ Pros | ❌ Cons |
|---|---|
| Fast reads | Repeated data uses more storage |
| No JOINs needed | You must update many places when data changes |
| Predictable performance | Harder to keep data consistent |

Techniques: embed data in the item, store lists/maps, **single-table design**, use Streams to sync copies.

---

## 16. Considerations When Creating Tables

### Checklist

- **Primary key:** choose carefully. ⚠️ You **cannot change** it after creation.
- **Capacity mode:**

| | On-Demand | Provisioned |
|---|---|---|
| You set capacity? | No | Yes (RCU / WCU) |
| Pay for | Each request | Reserved capacity |
| Best for | Unknown or spiky traffic | Predictable traffic |
| Autoscaling | Not needed | Available |

- **Table class:** *Standard* (default) or *Standard-IA* (cheaper storage for rarely used data).
- **Local Secondary Indexes (LSI):** can only be created **when the table is created**.
- **Global Secondary Indexes (GSI):** can be added later.
- **Item size:** keep items small (max **400 KB**).
- **TTL (Time to Live):** automatically delete old items (free).
- **Encryption:** always on (AWS-owned key by default, or KMS key).
- **Backups:** enable **Point-in-Time Recovery (PITR)** and on-demand backups.
- **Deletion protection:** enable it for production tables.
- **Attribute names:** short names save storage and cost.
- **Tags:** use them for cost tracking.

---

## 17. Secondary Indexes: GSI and LSI

By default you can only search by the **primary key**. A **secondary index** gives you **another way to query** the same data.

### What is a GSI (Global Secondary Index)?

- A **different** partition key (and optional sort key) from the table.
- Can be created **at any time**.
- Has its **own capacity** (RCU/WCU).
- Reads are **eventually consistent only**.
- Default limit: **20 GSIs** per table.
- Key values do not need to be unique.

### What is an LSI (Local Secondary Index)?

- The **same partition key** as the table, but a **different sort key**.
- Can **only be created when the table is created**.
- Shares the capacity of the table.
- Supports **strong consistency**.
- Limit: **5 LSIs** per table.
- Limit: **10 GB** per partition key value.
- Only available on tables with a **composite key**.

### GSI vs LSI

| Feature | GSI | LSI |
|---|---|---|
| Partition key | Different | **Same** as table |
| Sort key | Different | Different |
| Create when? | Any time | Only at table creation |
| Capacity | Own capacity | Shares table capacity |
| Strong consistency | ❌ No | ✅ Yes |
| Max per table | 20 (default) | 5 |
| Size limit | None | 10 GB per partition key |

### Projection (what the index copies)

- `KEYS_ONLY`: only the keys.
- `INCLUDE`: keys + some attributes you choose.
- `ALL`: all attributes.

### Example

Table: PK = `CustomerId`, SK = `OrderDate`.
Need: "all orders with status SHIPPED" → create a **GSI** with PK = `Status`, SK = `OrderDate`.

```python
table.query(
    IndexName="Status-OrderDate-index",
    KeyConditionExpression=Key("Status").eq("SHIPPED")
)
```

---

## 18. Locks

DynamoDB **does not have traditional locks** (no row locks, no table locks like in SQL). Instead, it uses **optimistic locking**.

### Optimistic locking

Idea: *"Assume nobody else is changing this item. When I save, check that the item has not changed."*

Steps:

1. Add a `version` attribute to the item.
2. Read the item and remember its version.
3. Update with a **condition**: the version must be the same.
4. If another process changed it first, the update **fails** and you retry.

```python
from botocore.exceptions import ClientError

try:
    table.update_item(
        Key={"UserId": "u-1"},
        UpdateExpression="SET Balance = :b, version = :new",
        ConditionExpression="version = :old",
        ExpressionAttributeValues={":b": 90, ":old": 3, ":new": 4}
    )
except ClientError as e:
    if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
        print("Item changed. Read again and retry.")
```

### Related tools

- **Conditional writes:** `attribute_not_exists(UserId)` prevents overwriting an existing item.
- **Atomic counters:** `SET Counter = Counter + :inc`.
- **Transactions:** all-or-nothing changes (see below).
- **Distributed lock (advanced):** the *DynamoDB Lock Client* library can build locks using conditional writes + TTL.

---

## 19. Autoscaling

Autoscaling changes **provisioned capacity** (RCU/WCU) automatically when traffic changes.

### How it works

- Uses **AWS Application Auto Scaling** and **CloudWatch alarms**.
- You set:
  - **Minimum** capacity
  - **Maximum** capacity
  - **Target utilization** (e.g., 70%)
- If usage goes above the target, capacity goes up. If usage goes down, capacity goes down.
- Works separately for **read** and **write**, and for **tables** and **GSIs**.

### Autoscaling vs On-Demand

| | Provisioned + Autoscaling | On-Demand |
|---|---|---|
| Reaction to sudden spikes | Slower (needs minutes) | Instant |
| Cost | Lower for steady traffic | Higher per request |
| Control | You set min/max | Fully automatic |

> ⚠️ Autoscaling is for **provisioned mode only**. On-demand mode scales by itself.
> Tip: **Burst capacity** helps with short spikes, but do not depend on it.

---

## 20. DynamoDB Streams

A **stream** is an ordered log of **changes** (insert, update, delete) in a table.

### Key facts

- Each change is a **stream record**.
- Records are kept for **24 hours**.
- Order is guaranteed **per item (per key)**.
- Each record appears **exactly once**.
- Enable it per table.

### Stream view types

| View type | What the record has |
|---|---|
| `KEYS_ONLY` | Only the key attributes |
| `NEW_IMAGE` | The item **after** the change |
| `OLD_IMAGE` | The item **before** the change |
| `NEW_AND_OLD_IMAGES` | Both before and after |

### Common uses

- Trigger **AWS Lambda** when data changes.
- Send notifications (email, SNS).
- Keep a copy in **OpenSearch** or another database.
- Audit and history logs.
- Update aggregated or denormalized data.

```
DynamoDB Table → Stream → Lambda → (SNS / S3 / OpenSearch)
```

> 💡 Similar option: **Kinesis Data Streams for DynamoDB** (longer retention, more consumers).

---

## 21. Transactions

A **transaction** groups several operations into **one all-or-nothing** action (**ACID**).

- Either **all** operations succeed, or **none** do.
- Use `TransactWriteItems` and `TransactGetItems`.
- Can include up to **100 items** or **4 MB** of data.
- Items can be in **different tables** (same account and Region).
- Operations: `Put`, `Update`, `Delete`, `ConditionCheck`.
- Cost: transactions use **2x** the capacity (one to prepare, one to commit).
- Strongly consistent, isolated from other operations.
- One item cannot appear twice in the same transaction.

### Example: transfer money

```python
client = boto3.client("dynamodb")

client.transact_write_items(
    TransactItems=[
        {"Update": {
            "TableName": "Accounts",
            "Key": {"AccountId": {"S": "A"}},
            "UpdateExpression": "SET Balance = Balance - :amt",
            "ConditionExpression": "Balance >= :amt",
            "ExpressionAttributeValues": {":amt": {"N": "50"}}
        }},
        {"Update": {
            "TableName": "Accounts",
            "Key": {"AccountId": {"S": "B"}},
            "UpdateExpression": "SET Balance = Balance + :amt",
            "ExpressionAttributeValues": {":amt": {"N": "50"}}
        }}
    ]
)
```

If account A does not have enough money, **nothing changes** in either account.

---

## 22. Global Tables

**Global Tables** automatically copy your data across **multiple AWS Regions**.

### Key facts

- **Multi-Region** and **multi-active**: you can **read and write in every Region**.
- Replication is **automatic** and usually takes **about a second**.
- Benefits:
  - **Low latency** for users around the world.
  - **High availability** and disaster recovery.
- Conflict rule: **last writer wins** (latest timestamp).
- Replication is **eventually consistent** between Regions.
- Requirements: **DynamoDB Streams** enabled and the same table name in all Regions.
- You pay for the **replicated write capacity** in each Region.

```
   US-East  ⇄  Europe  ⇄  Asia
 (read/write) (read/write) (read/write)
```

> ⚠️ Strongly consistent reads only work in the **same Region where the write happened**.

---

## 23. Column and Row Level Permissions

DynamoDB uses **IAM policies** for **fine-grained access control**. The permissions are set with **condition keys**.

### Row-level (item) access: `dynamodb:LeadingKeys`

Allow users to access **only items whose partition key matches their identity**.

```json
{
  "Effect": "Allow",
  "Action": ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:PutItem"],
  "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/UserData",
  "Condition": {
    "ForAllValues:StringEquals": {
      "dynamodb:LeadingKeys": ["${cognito-identity.amazonaws.com:sub}"]
    }
  }
}
```

Each user can only read/write rows where `UserId` = their own ID.

### Column-level (attribute) access: `dynamodb:Attributes`

Allow users to access **only certain attributes**.

```json
{
  "Effect": "Allow",
  "Action": ["dynamodb:GetItem", "dynamodb:Query"],
  "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/UserData",
  "Condition": {
    "ForAllValues:StringEquals": {
      "dynamodb:Attributes": ["UserId", "Name", "City"]
    },
    "StringEqualsIfExists": {
      "dynamodb:Select": "SPECIFIC_ATTRIBUTES"
    }
  }
}
```

Users can only see `UserId`, `Name` and `City` (not `Salary`, for example).

### Setup steps

1. Identify who needs access (IAM role, user, or Cognito identity).
2. Write an IAM policy with the right **actions** and **resource** (table or index ARN).
3. Add **conditions**: `dynamodb:LeadingKeys` (rows) and/or `dynamodb:Attributes` (columns).
4. Add `dynamodb:Select` so users must request specific attributes.
5. Attach the policy to the role/user.
6. **Test** with the IAM policy simulator.

### Remember

- Apply the **least privilege** principle.
- For indexes, add the index ARN: `table/UserData/index/*`.
- Other helpful keys: `dynamodb:ReturnValues`, `dynamodb:EnclosingOperation`.
- Use **CloudTrail** to audit access.

---

## 24. Quick Review Cheat Sheet

| Topic | Remember |
|---|---|
| DynamoDB | Serverless NoSQL, key-value + document |
| Item limit | 400 KB |
| Primary key | Simple (PK) or composite (PK + SK); cannot change later |
| Good PK | High cardinality, even distribution |
| Query | Fast, uses the key |
| Scan | Reads everything, avoid it |
| Filter expression | Applied after reading, does not save cost |
| Eventual consistency | Default, cheaper, may be old data |
| Strong consistency | Latest data, 2x cost, not on GSI |
| GSI | Any key, any time, own capacity, eventual only |
| LSI | Same PK, only at creation, strong consistency OK, 5 max |
| Locks | Use optimistic locking with condition expressions |
| Autoscaling | Provisioned mode only |
| Streams | Change log, 24 hours, triggers Lambda |
| Transactions | ACID, up to 100 items, 2x cost |
| Global Tables | Multi-Region, multi-active, last writer wins |
| Fine-grained access | `LeadingKeys` (rows), `Attributes` (columns) |

### Design mantra

> **Know your access patterns → choose your keys → add indexes only when needed → denormalize.**

---

*Good luck with your studies! 🚀*
