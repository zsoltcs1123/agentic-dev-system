# {Tracker Name} Adapter — sync-tasks

Adapter interface for the sync-tasks skill. Copy this file, rename to `{tracker-name}.md`, and fill in the operations.

## Prerequisites

- {What needs to be installed/configured, e.g. CLI tool, MCP server}

## Settings

- {Tracker-specific settings, e.g. project ID, owner}

## Operations

### Create Item

{Command or MCP call to create a task/issue}

Inputs: `{title}`, `{body}`
Output: item ID (store as `trackerId` in state.json)

### List Items

{Command to list all items, output as JSON}

### Get Item

{Command to get a single item by ID}
