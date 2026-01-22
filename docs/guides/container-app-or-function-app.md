# When to Use Container Apps vs Function Apps

## Overview

Azure offers two main compute options for containerized workloads: **Container Apps** and **Function Apps**. While both can technically host any type of application, they're optimised for different scenarios.

**What is a "main application"?** In this context, we're referring to your primary user-facing service - typically a web application, REST API, or UI that end users or other systems interact with directly and expect to be responsive and available.

**Both options are valid for hosting your main application,** but the guidelines below will help you choose based on operational best practices, performance characteristics, and cost efficiency.

## Quick Decision Guide

## Use Container Apps for:
- **Always-on services** that need consistent availability and predictable response times
- **Custom runtime requirements** (any language, framework, or base image)
- **Avoiding vendor lock-in** to Azure Functions runtime
- **Long-running requests** (up to 30 minutes per request)
- **WebSocket connections** or Server-Sent Events (SSE)
- **Consistent performance** without cold start delays
- **Main application UI** where users expect instant page loads

## Use Function Apps for:
- **Scheduled background tasks** (timer-based CRON jobs)
- **Event-driven processing** (queue, blob, or event-based triggers)
- **Short-lived operations** (typically < 5 minutes)
- **Consumption-based pricing** for sporadic workloads
- **Workloads tolerant of cold starts** (1-10 second delays when scaling from zero)

## Running Main Applications on Function Apps

You *can* run your main application and UI on Function Apps - they can provide APIs, autoscale based on request volume, and have public endpoints, but consider these trade-offs:

**Advantages:**
- **Unified platform** - single service for both web and background jobs
- **Consumption pricing** - pay only for actual execution time (if using Consumption plan)
- **Built-in bindings** - convenient integrations with Azure services

**Disadvantages:**
- **Cold start latency** - 1-10 second delays on first request after idle period
- **Runtime overhead** - Azure Functions runtime adds initialisation time and abstraction layer
- **Less control** - functions framework constrains application structure
- **Storage requirement** - must provision and pay for dedicated storage account for Functions internal state
- **Complexity** - additional environment variables and configuration compared to direct container execution

**When Function Apps make sense for main apps:**
- Low-traffic applications where cold starts are acceptable
- Prototypes and demos where simplicity matters more than performance
- Applications already heavily invested in Functions ecosystem
- Scenarios where unified monitoring/logging across HTTP and event triggers is valuable

## Cold Start Behavior

**Function Apps:**
- **Cold starts can occur even with min instances > 0** due to Functions runtime initialisation
- **Typical cold start:** 1-3 seconds for Python Functions runtime + your application code
- **Mitigation:** Use "always ready" instances (Premium plan) to pre-warm instances, but still incurs runtime overhead
- **Best for:** Background jobs where occasional latency spikes are acceptable

**Container Apps:**
- **With min replicas = 0:** Cold start occurs when scaling from zero (container image pull + app initialization)
- **With min replicas > 0:** No cold starts (at least one instance always running)
- **PROD recommendation:** min replicas = 2 eliminates cold starts entirely


See [Container Apps documentation](../services/container-apps.md) for details on configuration, scaling, and managed identity setup.

See [Function Apps documentation](../services/function-apps.md) for details on scheduled tasks and event-driven processing.