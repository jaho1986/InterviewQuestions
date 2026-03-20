# Scalability Patterns – Pipes and Filters

## Overview
The **Pipes and Filters** pattern structures a system as a sequence of independent processing stages (filters) connected by data channels (pipes). Data flows from a source through multiple transformation stages to a final destination — each filter performing one focused operation in isolation.

---

## Core Terminology

| Term | Definition | Examples |
|---|---|---|
| **Data Source** | Origin of the data or trigger | Backend service receiving user requests, IoT sensor collector, FaaS function |
| **Filter** | An isolated component that performs one single operation on the data | Video encoder, transcriber, content classifier |
| **Pipe** | The channel connecting filters | Distributed queue or message broker |
| **Data Sink** | Final destination after all processing stages | Internal database, distributed file system, external service |

> Filters are **stateless** and **completely unaware** of the rest of the pipeline — they only know their input and output.

> Data doesn't always need to flow through the pipes directly — it can be stored in a temporary location (file system, database) and a notification with the data's location is sent instead.

---

## The Problem It Solves

A monolithic approach to multi-stage data processing creates three problems:

| Problem | Detail |
|---|---|
| **Tight coupling of tech stacks** | All stages must use the same programming language — can't mix Python (ML), Java (business logic), C++ (CPU-heavy operations) |
| **Hardware mismatch** | Different stages need different hardware (ML accelerators, high CPU, high memory, high bandwidth) — impossible to optimize when everything runs on one machine |
| **Inflexible scaling** | Can't scale individual stages independently — all or nothing |

**With Pipes and Filters:**
- Each filter uses the **optimal language/ecosystem** for its task
- Each filter runs on **optimal hardware** for its workload
- Each filter is **independently scaled** based on its throughput needs
- Independent filters can run **in parallel** on separate machines for higher throughput

---

## Real-World Example: Video Processing Pipeline

When a user uploads a video to a sharing platform, it goes through the following pipeline:

```
[Uploaded Video]
       ↓
┌──────────────────────┐
│  Split into chunks   │  → enables chunk-by-chunk streaming
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│  Extract thumbnails  │  → one frame per chunk for seeking UI
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│  Resize to multiple  │  → supports adaptive streaming
│  resolutions/bitrates│    (quality adjusts to network speed)
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│  Encode to multiple  │  → supports different devices/players
│  formats             │
└──────────────────────┘

[Parallel Audio Pipeline]
       ↓
┌──────────────────────┐
│  Speech Transcription│  → NLP + specialized hardware
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│  Translation +       │  → captions in multiple languages
│  Captioning          │
└──────────────────────┘

[Parallel Content Safety Pipeline]
       ↓
┌──────────────────────┐
│  Copyright + Content │  → flag for manual review or auto-reject
│  Detection           │
└──────────────────────┘
```

**Industries where this pattern is widely used:**
- Digital advertising (user activity stream processing)
- Internet of Things (sensor data processing)
- Image and video processing pipelines

---

## Important Considerations

### 1. Overhead vs. Granularity
This pattern introduces architectural complexity. If filters are too granular, the overhead of managing many separate components outweighs the benefits. **Balance separation with practicality.**

### 2. Each Filter Must Be Stateless
Every filter must receive all the information it needs as part of its input. Filters must not depend on shared memory or state from other filters.

### 3. Not Suitable for Transactional Workflows
If all stages of the pipeline must succeed or fail as an atomic unit (a transaction), this pattern is a poor fit. Distributed transactions across independent components are extremely complex and inefficient.

---

## Summary

| Aspect | Key Point |
|---|---|
| **Pattern structure** | Data Source → Filters (via Pipes/Queues) → Data Sink |
| **Filter design** | One operation per filter; stateless; unaware of the pipeline |
| **Main benefits** | Tech flexibility, hardware optimization, independent scaling, parallel execution |
| **Best use cases** | Stream processing, IoT data, video/image/audio pipelines, ad analytics |
| **Avoid when** | All stages must be part of a single transaction |
| **Key pitfall** | Too many granular filters → complexity outweighs benefit |
