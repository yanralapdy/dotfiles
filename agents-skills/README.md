# Agent Skills

Single canonical home for skills used by **kiro** and **pi** coding agents.

## Layout

```
~/.dotfiles/agents-skills/
├── skills/                 # Canonical source — every skill lives here
│   ├── handoff/
│   ├── tdd/
│   ├── diagnose/
│   └── ...
├── AGENTS.md               # Full inventory of agents and skills
└── README.md               # This file
```

Each skill is a directory containing at minimum a `SKILL.md`. Some skills also bundle scripts, templates, or reference files.

## How It Works

Both agents discover skills from the same directory through symlinks. Editing a skill in `~/.dotfiles/agents-skills/skills/<name>/` immediately affects both kiro and pi.

```
~/.dotfiles/agents-skills/skills/       ← canonical source
        ↑
        ├── ~/.config/kiro/skills/      ← symlink
        ├── ~/.kiro/skills/             ← symlink
        ├── ~/.dotfiles/kiro/.config/kiro/skills/   ← symlink
        ├── ~/.dotfiles/kiro/.kiro/skills/          ← symlink
        ├── ~/.dotfiles/pi/.config/pi/agent/skills/ ← symlink
        └── ~/.pi/agent/skills/                     ← symlink
```

## Setup (for agents / new machines)

If you are setting this up from scratch:

1. Ensure the canonical directory exists:
   ```bash
   ls ~/.dotfiles/agents-skills/skills
   ```

2. Remove any existing kiro/pi skill directories (not symlinks) and replace them with symlinks:
   ```bash
   CANONICAL="$HOME/.dotfiles/agents-skills/skills"

   # Kiro
   rm -rf ~/.config/kiro/skills
   ln -s "$CANONICAL" ~/.config/kiro/skills

   rm -rf ~/.kiro/skills
   ln -s "$CANONICAL" ~/.kiro/skills

   # Kiro dotfiles mirrors (if present)
   rm -rf ~/.dotfiles/kiro/.config/kiro/skills
   ln -s "$CANONICAL" ~/.dotfiles/kiro/.config/kiro/skills

   rm -rf ~/.dotfiles/kiro/.kiro/skills
   ln -s "$CANONICAL" ~/.dotfiles/kiro/.kiro/skills

   # Pi
   rm -rf ~/.dotfiles/pi/.config/pi/agent/skills
   ln -s "$CANONICAL" ~/.dotfiles/pi/.config/pi/agent/skills

   rm -rf ~/.pi/agent/skills
   ln -s "$CANONICAL" ~/.pi/agent/skills
   ```

3. Verify every path resolves to the canonical source:
   ```bash
   for p in ~/.config/kiro/skills ~/.kiro/skills ~/.dotfiles/kiro/.config/kiro/skills \
            ~/.dotfiles/kiro/.kiro/skills ~/.dotfiles/pi/.config/pi/agent/skills \
            ~/.pi/agent/skills; do
     printf "%-55s -> %s\n" "$p" "$(readlink "$p")"
   done
   ```

4. Confirm both agents can list the same skills:
   ```bash
   ls ~/.config/kiro/skills | wc -l
   ls ~/.pi/agent/skills | wc -l
   # Both should show 37 (or current skill count)
   ```

## Adding a New Skill

1. Create a directory under `~/.dotfiles/agents-skills/skills/<skill-name>/`
2. Add a `SKILL.md` following the standard skill structure:
   - **Name** — short, kebab-case
   - **Description** — one-line trigger for when to load the skill
   - **Usage** — how the agent should invoke it
   - **Instructions** — the actual workflow/prompt
   - **Examples / References** — optional supporting files
3. Both kiro and pi will discover it automatically on next load.

See the `write-a-skill` skill for a detailed template.

## Modifying an Existing Skill

1. Edit the canonical copy only:
   ```bash
   # Good
   nvim ~/.dotfiles/agents-skills/skills/<skill-name>/SKILL.md

   # Bad — do not edit through a symlink target thinking it is separate
   nvim ~/.config/kiro/skills/<skill-name>/SKILL.md   # same file, fine
   ```
2. Never create kiro-specific or pi-specific copies. If a skill needs environment-aware behavior, handle the branch inside the skill instructions.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Kiro/pi don't see a new skill | Check that `~/.config/kiro/skills` and `~/.pi/agent/skills` are symlinks, not real directories. |
| Symlink was replaced with a real dir by an update | Re-run the setup commands above. |
| Skill content differs between kiro and pi | You have duplicate copies. Delete all non-canonical skill dirs and re-create symlinks. |
| `readlink` returns wrong path | Remove the symlink and recreate it pointing to `~/.dotfiles/agents-skills/skills`. |

## History

This repo evolved from a standalone `kiro-skills` directory into `agents-skills` so that kiro and pi share one source of truth. The previous duplicate copies across `~/.dotfiles/kiro/.config/kiro/skills/` and `~/.dotfiles/pi/.config/pi/agent/skills/` were removed and replaced with symlinks.

See `AGENTS.md` for the current agent definitions and skill catalog.
