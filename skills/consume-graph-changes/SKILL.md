---
name: consume-graph-changes
description: Consume and decode Kafka messages from the twins.network-twin.graph-changed topic on localhost. Use when user asks to "consume graph changes", "show graph changes", "inspect graph change events", or "read twin graph messages".
disable-model-invocation: true
allowed-tools: Bash
---

# Consume Graph Changes

Consume the last 500 messages from the `twins.network-twin.graph-changed` Kafka topic on localhost, decode each one using the `graph-changed-payload` tool, and display the results.

## Hard Rules

- **Never** modify, edit, or create any source files
- **Never** push to any remote or switch branches
- **Always** build the decoder tool fresh before consuming

## Procedure

### 1. Build the decoder tool

Compile the graph-changed-payload tool to a temporary location:

```bash
go build -o /tmp/graph-changed-payload /Users/vedranjanjetovic/code/atmosphere/tools/graph-changed-payload
```

If the build fails, report the error and stop.

### 2. Consume and decode messages

Loop through the last 500 messages, one at a time. For each iteration, starting at offset -500 and incrementing toward -1:

```bash
kcat -C -b localhost:9092 -t twins.network-twin.graph-changed -o <offset> -c 1 -e -f '%s' > /tmp/graph-changed.bin
```

Then decode and display:

```bash
/tmp/graph-changed-payload /tmp/graph-changed.bin
```

Display the decoded output to the user before moving to the next message. Reuse the same `/tmp/graph-changed.bin` file for each iteration.
