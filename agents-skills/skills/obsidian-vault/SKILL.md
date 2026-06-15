---
name: obsidian-vault
description: Read, search, create, and update notes in an Obsidian vault. Use when user mentions Obsidian, wants to save notes to their vault, search their knowledge base, or reference vault content.
---

# Obsidian Vault

Interact with the user's Obsidian vault as a knowledge base.

## Vault Location

Primary vault: `~/Downloads/work/notes/`

To create a new vault, create a new directory and add a `.obsidian/` folder inside it.

## Capabilities

### Search
- Search note titles and content using grep/glob
- Follow `[[wikilinks]]` to find related notes
- Read frontmatter (YAML) for metadata/tags

### Create Notes
When creating notes, follow Obsidian conventions:
- Use markdown with `[[wikilinks]]` for internal links
- Add YAML frontmatter with tags, date, aliases
- Place in appropriate folder based on vault structure
- Use the vault's existing naming convention (kebab-case, spaces, etc.)

```markdown
---
tags: [topic, subtopic]
date: {{date}}
aliases: []
---

# Note Title

Content here. Link to [[Related Note]].
```

### Update Notes
- Append to daily notes
- Add backlinks to existing notes
- Update tags or frontmatter

## Rules
- Never delete notes without explicit permission
- Preserve existing formatting and link structure
- Respect the vault's folder hierarchy
- Use `[[wikilinks]]` not `[markdown](links)` for internal references
- Check if a note exists before creating a duplicate
