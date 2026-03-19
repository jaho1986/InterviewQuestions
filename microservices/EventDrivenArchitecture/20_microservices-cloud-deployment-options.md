# Microservices Deployment – Cloud Infrastructure Options

## Overview
Once microservices are built and tested, they need to run somewhere. This lecture covers the main **cloud deployment options** using virtual machines, focusing on the trade-offs between cost, security, and performance.

---

## Background: What is a Virtual Machine (VM)?

A VM is an isolated environment running on top of a physical server, with its own virtual OS, CPU, memory, network, and storage. A layer of software called the **hypervisor** manages and maps virtual resources to real hardware — allowing one physical server to host multiple VMs.

---

## Option 1 – Multi-Tenant Cloud VMs

Multiple customers share the same physical server, each in their own VM. The cloud provider allocates resources based on the configuration (and pricing tier) selected.

**Pricing:** Pay-per-use — you pay only for what you rent, for how long you rent it.

### ✅ Benefits
- Most **affordable** option — cloud providers can efficiently utilize hardware across many customers
- **Flexible pricing** — scale up or down as needed

### ❌ Drawbacks

**1. Security risk (multi-tenancy)**
- VMs on the same host are theoretically isolated, but the hypervisor is software written and managed by humans
- A poorly secured VM from another organization on the same host could, in rare cases, expose your data
- **Industries that cannot accept this risk:** banking, healthcare, government/national security

**2. Noisy neighbor effect**
- Not all hardware resources can be perfectly partitioned (e.g. network bandwidth, internal bus access)
- A resource-intensive workload on a neighboring VM can subtly degrade your VM's performance
- **Services sensitive to this:** high-frequency trading, gaming, video streaming

---

## Option 2 – Single-Tenant Dedicated Instances

The cloud provider runs your VMs only on servers dedicated to your organization — no other company's workloads run on the same host.

### ✅ Benefits
- Eliminates the **security risk** of multi-tenancy — suitable for regulated industries
- Reduces the **noisy neighbor** effect

### ❌ Drawbacks
- More **expensive** than multi-tenant VMs — the provider cannot utilize hardware as efficiently

---

## Option 3 – Dedicated Hosts (Full Host Rental)

Your organization rents an **entire physical server**, with direct access to all of its hardware resources.

### ✅ Benefits
- **Completely eliminates** the noisy neighbor effect
- **Reduces virtualization overhead** from the hypervisor
- Maximum performance isolation

### ❌ Drawbacks
- **Most expensive** option by far

---

## Comparison Summary

| Option | Cost | Security | Performance | Best For |
|---|---|---|---|---|
| **Multi-tenant VMs** | Lowest | ⚠️ Shared hardware | ⚠️ Noisy neighbor risk | Most workloads — best default |
| **Dedicated instances** | Medium | ✅ Org-only hardware | ✅ Better isolation | Regulated industries (banking, healthcare, gov) |
| **Dedicated hosts** | Highest | ✅ Full isolation | ✅ Maximum performance | Latency-critical systems (trading, gaming, streaming) |

> The right choice depends on your organization's security compliance requirements and performance sensitivity. Most companies start with multi-tenant VMs and only upgrade specific services when necessary.
