# {Tracker Name} Adapter — add-task

Adapter interface for the add-task skill. Copy this file, rename to `{tracker-name}.md`, and fill in the operations.

## Prerequisites

- {What needs to be installed/configured, e.g. CLI tool, MCP server}

## Settings

- {Tracker-specific settings, e.g. project ID, owner}

## Operations

### Create Item

{Command or MCP call to create a task/issue}

Inputs: `{title}`, `{body}`, optional `{labels}`, `{phase}`
Output: item ID (store as `trackerId` in state.json)
