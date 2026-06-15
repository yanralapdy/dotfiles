/**
 * Mode Switcher Extension
 *
 * Provides /mode command to switch between agent personas/modes.
 * Agents are defined in ~/.config/pi/agent/agents/*.json.
 *
 * Available modes:
 * - architect     - Design systems, produce specs
 * - builder       - Implement code from specs
 * - code-reviewer - Review code for bugs, security, performance
 * - researcher    - Explore codebases, summarize findings
 * - orchestrator  - Coordinate multi-agent dev pipeline
 * - documenter   - Update docs, READMEs, changelogs
 *
 * Sub-agents (cheaper models, invoked by other agents):
 * - test-runner       - Run test/lint suites
 * - security-scanner  - Focused security scan
 * - doc-fetcher       - Fetch external docs
 */

import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

const MODES: Record<string, { label: string; description: string; prompt: string }> = {
    architect: {
        label: "Architect",
        description: "Analyze requirements, design systems, produce specs",
        prompt: "You are now in architect mode. Analyze requirements, explore the codebase, and produce a detailed spec before any code is written. Load the skills: architecture-review, grill-me. Focus on understanding the problem deeply before proposing solutions.",
    },
    builder: {
        label: "Builder",
        description: "Implement code from specs, run tests",
        prompt: "You are now in builder mode. Read the spec, implement code matching existing patterns, run tests and linters. Load the skills: tdd, refactoring, git-workflow. Follow existing code style, write tests, make incremental changes.",
    },
    "code-reviewer": {
        label: "Code Reviewer",
        description: "Review code for bugs, security, performance, style",
        prompt: "You are now in code reviewer mode. Compare implementation against specs, check for correctness/security/performance/style. Load the skills: security, performance, testing, debugging. Produce a structured review with pass/fail verdict.",
    },
    researcher: {
        label: "Researcher",
        description: "Explore codebases, summarize findings",
        prompt: "You are now in researcher mode. Explore the codebase, gather information, and synthesize findings. Do not write code — only research and report. Use grep, glob, and read tools to investigate.",
    },
    orchestrator: {
        label: "Orchestrator",
        description: "Coordinate multi-agent dev pipeline (architect → builder → reviewer)",
        prompt: "You are now in orchestrator mode. Coordinate the dev pipeline: architect → builder → code-reviewer. Break tasks into stages, delegate to appropriate modes, track progress. Load the skills: handoff, caveman. Keep messages brief — you are a coordinator.",
    },
    documenter: {
        label: "Documenter",
        description: "Update docs, READMEs, changelogs",
        prompt: "You are now in documenter mode. Read specs and review notes, then update documentation. Update API docs, README.md, and CHANGELOG.md. Load the skill: stop-slop. Be concise, include usage examples, never document things that weren't implemented.",
    },
};

export default function (pi: ExtensionAPI) {
    pi.registerCommand("mode", {
        description: `Switch between agent modes. Available: ${Object.keys(MODES).join(", ")}. Usage: /mode <name>`,
        getArgumentCompletions: (prefix: string) => {
            const filtered = Object.keys(MODES).filter(m => m.startsWith(prefix.toLowerCase()));
            return filtered.length > 0
                ? filtered.map(m => ({ value: m, label: `${m} - ${MODES[m].description}` }))
                : null;
        },
        handler: async (args: string, ctx: ExtensionCommandContext) => {
            const mode = args.trim().toLowerCase();

            if (!mode) {
                const modeList = Object.entries(MODES)
                    .map(([key, val]) => `  ${key.padEnd(16)} ${val.description}`)
                    .join("\n");
                ctx.ui.notify(`Available modes:\n${modeList}\n\nUsage: /mode <name>\nSub-agents: test-runner, security-scanner, doc-fetcher`, "info");
                return;
            }

            if (!(mode in MODES)) {
                ctx.ui.notify(`Unknown mode: ${mode}\nAvailable: ${Object.keys(MODES).join(", ")}`, "error");
                return;
            }

            const config = MODES[mode];
            ctx.ui.notify(`✓ Switched to ${config.label} mode\n${config.description}\n\nLoading skills for ${mode}...`, "success");
            return config.prompt;
        },
    });
}