# {Tracker Name} Adapter — update-task-status

Adapter interface for the update-task-status skill. Copy this file, rename to `{tracker-name}.md`, and fill in the operations.

## Prerequisites

- {What needs to be installed/configured, e.g. CLI tool, MCP server}

## Settings

- {Tracker-specific settings, e.g. project ID, status field mappings}

## State Mapping

Map local task states to tracker statuses:

| Local State | Tracker Status |
| ----------- | -------------- |
| PENDING     | {value}        |
| PLANNED     | {value}        |
| IMPLEMENTED | {value}        |
| REVIEWED    | {value}        |
| VERIFIED    | {value}        |
| DOCUMENTED  | {value}        |
| COMMITTED   | {value}        |
| PR_CREATED  | {value}        |
| DONE        | {value}        |
| BLOCKED     | {value}        |

## Operations

### Update Item Status

{Command or MCP call to update an item's status}

Inputs: `{trackerId}`, `{status}`

### Get Item Status

{Command to read current status of an item from the tracker}

Inputs: `{trackerId}`
Output: current tracker status
