/**
 * Workflow Orchestrator Extension (Passive by Default)
 *
 * Provides plan mode and multi-step workflow orchestration for Pi.
 * Agents are defined in ~/.config/pi/agent/agents/*.json.
 *
 * Pipeline: architect → builder → code-reviewer (→ documenter)
 * Sub-agents: researcher, test-runner, security-scanner, doc-fetcher
 */

import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

interface PlanStep {
    step: number;
    name: string;
    mode: string;
    prompt: string;
    done: boolean;
}

const workflows = new Map<string, PlanStep[]>();
let activated = false;

export default function (pi: ExtensionAPI) {
    // Register activation command
    pi.registerCommand("workflow-orchestrator", {
        description: "Activate workflow orchestrator (loads /plan, /workflow, spawn-agent tool)",
        handler: async (_args: string, ctx: ExtensionCommandContext) => {
            if (activated) {
                ctx.ui.notify("Workflow orchestrator is already active!", "info");
                return;
            }

            activateWorkflowOrchestrator(pi);
            activated = true;
            ctx.ui.notify("✓ Workflow orchestrator activated! Commands: /plan, /workflow", "success");
        },
    });

    // Restore activation on session resume
    pi.on("session_start", async (_event, ctx) => {
        const entries = ctx.sessionManager.getEntries();
        const hasActivationMarker = entries.some(
            (e) => e.type === "custom" && e.customType === "workflow-orchestrator-active"
        );

        if (hasActivationMarker && !activated) {
            activateWorkflowOrchestrator(pi);
            activated = true;
            ctx.ui.notify("Workflow orchestrator restored from session", "info");
        }
    });

    // On before_agent_start, inject mode prompt if a mode is active
    pi.on("before_agent_start", async (event, _ctx) => {
        // Mode prompts are injected via /mode command return values
        // No additional injection needed here
    });
}

function activateWorkflowOrchestrator(pi: ExtensionAPI) {
    // Register /plan command
    pi.registerCommand("plan", {
        description: "Create a step-by-step plan for a task, identifying which agent handles each step",
        handler: async (args: string, _ctx: ExtensionCommandContext) => {
            const task = args.trim();
            if (!task) {
                return "Usage: /plan <describe your task>";
            }

            const planPrompt = `Create a step-by-step plan for: ${task}

Break the task into clear steps. For each step, specify:
- Step name
- Which agent mode to use (researcher, architect, builder, code-reviewer, documenter, or none for manual)
- Brief description of what to do

Available agent modes:
- architect: Analyze requirements, produce specs, design systems
- builder: Implement code from specs, run tests
- code-reviewer: Review code for bugs, security, performance, style
- documenter: Update docs, README, changelogs
- researcher: Explore codebase, summarize findings (no code changes)

Available sub-agents (invoked by other agents):
- test-runner: Run test/lint suites
- security-scanner: Focused security scan
- doc-fetcher: Fetch external library docs

Format as a numbered list with agent assignments.`;

            return planPrompt;
        },
    });

    // Register /workflow command
    pi.registerCommand("workflow", {
        description: "Manage workflow execution: /workflow list | /workflow run <name>",
        handler: async (args: string, _ctx: ExtensionCommandContext) => {
            const parts = args.split(/\s+/);
            const subcommand = parts[0];
            const rest = parts.slice(1).join(" ");

            if (subcommand === "list") {
                const workflowList = Array.from(workflows.entries())
                    .map(([name, steps]) => {
                        const completed = steps.filter(s => s.done).length;
                        return `  ${name}: ${completed}/${steps.length} steps done`;
                    })
                    .join("\n");
                return workflowList || "No active workflows. Use /plan to create one.";
            }

            if (subcommand === "run" && rest.length > 0) {
                return `Starting workflow: ${rest}\nUse /plan to create a plan first, then /mode orchestrator to coordinate execution.`;
            }

            return "Usage: /workflow list | /workflow run <name>";
        },
    });

    // Register spawn-agent tool
    pi.registerTool({
        name: "spawn-agent",
        label: "Spawn Agent",
        description: "Spawn a specialized sub-agent for a specific task. Available agents: researcher, architect, builder, code-reviewer, documenter, test-runner, security-scanner, doc-fetcher.",
        parameters: {
            type: "object",
            properties: {
                agent: {
                    type: "string",
                    enum: [
                        "researcher",
                        "architect",
                        "builder",
                        "code-reviewer",
                        "documenter",
                        "test-runner",
                        "security-scanner",
                        "doc-fetcher",
                    ],
                    description: "Which agent to spawn",
                },
                task: {
                    type: "string",
                    description: "Task description for the sub-agent",
                },
            },
            required: ["agent", "task"],
        },
        async execute(toolCallId: string, params: { agent: string; task: string }, signal: AbortSignal, onUpdate?: (update: any) => void, ctx?: any) {
            const agentDescriptions: Record<string, string> = {
                researcher: "Explore codebase and summarize findings",
                architect: "Analyze requirements and produce specs",
                builder: "Implement code from specs",
                "code-reviewer": "Review code for bugs, security, performance, style",
                documenter: "Update docs, README, changelogs",
                "test-runner": "Run test/lint suites and report results",
                "security-scanner": "Scan for security vulnerabilities",
                "doc-fetcher": "Fetch external library/API documentation",
            };

            const desc = agentDescriptions[params.agent] || "Unknown agent";
            const prompt = `[${params.agent} agent] ${desc}\n\nTask: ${params.task}`;

            onUpdate?.({
                content: [{ type: "text", text: `Spawning ${params.agent} agent...` }],
            });

            return {
                content: [{ type: "text" as const, text: prompt }],
                details: { agent: params.agent, task: params.task },
            };
        },
    });

    // Persist activation state
    pi.appendEntry("workflow-orchestrator-active", {
        activated: true,
        timestamp: Date.now(),
    });
}