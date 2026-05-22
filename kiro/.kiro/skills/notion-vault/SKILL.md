---
name: notion-vault
description: Read, search, create, and update pages in Notion via MCP. Use when user mentions Notion, wants to save notes/docs to Notion, search their Notion workspace, or reference Notion content.
---

# Notion Vault

Interact with the user's Notion workspace as a knowledge base via the Notion MCP server.

## Available Operations

Use the Notion MCP tools (`@notion`) to:

### Search
- Search pages and databases by title or content
- Query databases with filters (status, tags, dates)
- Retrieve page content by ID or title

### Create
- Create new pages under a specified parent
- Add content in blocks (paragraphs, headings, lists, code, callouts)
- Create database entries with properties

### Update
- Append content to existing pages
- Update page properties (status, tags, dates)
- Add comments to pages

## Conventions

When creating content in Notion:
- Use headings (H1, H2, H3) for structure
- Use callout blocks for important notes/warnings
- Use toggle blocks for collapsible sections
- Use code blocks with language specified
- Link to related pages using Notion page mentions

## Common Workflows

### Save meeting notes
Create a page with date, attendees, decisions, and action items.

### Document a decision
Create a page with context, options considered, decision made, and reasoning.

### Create a task/ticket
Add an entry to the relevant database with status, priority, and description.

### Save research
Create a page with source links, key findings, and personal notes.

## Rules
- Never delete pages without explicit permission
- Ask which database/parent page to use if unclear
- Respect existing page structure when appending
- Use the workspace's existing conventions for naming and organization
