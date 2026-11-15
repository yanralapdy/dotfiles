---
name: knowledge-manager
description: Read, search, create, update, and sync notes across Notion (via MCP) and Obsidian vaults. Use when user mentions Notion or Obsidian, wants to save notes, sync vaults to Notion, search across both systems, or work with their personal knowledge base.
---

# Knowledge Manager

Unified agent for managing knowledge across Notion (cloud) and Obsidian (local vaults).

## Systems

- **Notion** — workspace `yanral apdy's Space`, via the Notion MCP tools (`@notion`)
- **Obsidian** — local vaults at `~/Downloads/work/notes/` (new vault = new dir with a `.obsidian/` folder)

## Notion Workspace Context

### Key Pages
| Page | ID | Purpose |
|------|----|---------|
| Daily Todo List | `2b514b36-001a-8059-a4f5-c026e286b63d` | Daily task tracking with per-day databases |
| Daily Notes | `2c014b36-001a-80c1-8f34-fcdb9cd47a7f` | General daily notes |

### Daily Todo List Structure
- Each day is a separate **inline database** titled `Todo List YYYY-MM-DD`
- Today's database: `Todo List @Today` (ID: `36e14b36-001a-812b-b99c-ca655dcf4ff6`)
- Task properties: `Task name`, `Status` (Not started / In progress / Done), `Priority` (Low/Medium/High), `Assignee`, `Created At`, `Started At`, `Finished At`, `Description`
- Pattern for new day: create new inline database via REST API (`POST /v1/databases`), then add tasks
- Notion API token: available in `~/.kiro/settings/mcp.json`

### Obsidian Vaults in Notion
Each vault has been mirrored as a Notion page under the workspace root:
| Vault | Notion Page |
|-------|-------------|
| Prosper | Created in this session |
| Dotfiles | Created in this session |
| Primaclouds | Created in this session |
| DY | Created in this session |

## Obsidian Vaults

| Vault | Path | Topic |
|-------|------|-------|
| Prosper | `~/Downloads/work/notes/Prosper/` | Laravel+Vue insurance app (Prosper) — closings, DNCN, certificates |
| Dotfiles | `~/Downloads/work/notes/Dotfiles/` | GNU Stow dotfiles — zsh, nvim, tmux, kitty, karabiner, yazi |
| Primaclouds | `~/Downloads/work/notes/Primaclouds/` | Kompas Kasih — reproductive health education app (Laravel+Next.js) |
| DY | `~/Downloads/work/notes/DY/` | Kiro workshop notes, general dev notes |

## Conventions

**Notion:** H1–H3 for structure, callouts for warnings, toggles for collapsible sections, code blocks with language, page mentions for links. Ask which parent page/database to use if unclear.

**Obsidian:** `[[wikilinks]]` (not markdown links) for internal refs, YAML frontmatter, follow the vault's folder and naming conventions.

```markdown
---
tags: [topic, subtopic]
date: {{date}}
aliases: []
---

# Note Title

Content here. Link to [[Related Note]].
```

## Common Workflows

### Add today's tasks
1. Query today's database (`Todo List @Today`)
2. Create new entries with `POST /v1/pages` using the database ID

### Sync Obsidian note to Notion
1. Read the `.md` file
2. Find or create the corresponding Notion page
3. Append/update content blocks

### Search across both systems
1. Search Notion with `API-post-search`
2. Search Obsidian with `grep` on `~/Downloads/work/notes/**/*.md`
3. Merge and present results

### Create new daily todo database
```bash
curl -X POST https://api.notion.com/v1/databases \
  -H "Authorization: Bearer $TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  -d '{"parent": {"page_id": "2b514b36-001a-8059-a4f5-c026e286b63d"}, "is_inline": true, ...}'
```

## Rules
- Never delete Notion pages or Obsidian notes without explicit permission
- When syncing vault → Notion, preserve markdown structure
- Use the Daily Todo List page as the parent for all new todo databases
- Check if a Notion page already exists before creating a duplicate
