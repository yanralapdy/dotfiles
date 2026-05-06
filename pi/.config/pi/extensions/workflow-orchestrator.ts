/**
 * Workflow Orchestrator Extension (Passive by Default)
 * 
 * Provides plan mode and multi-step workflow orchestration for Pi.
 * Enables: research → plan → architect → build → review workflows.
 * 
 * ACTIVATION: Type /workflow-orchestrator to activate
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface WorkflowStep {
  name: string;
  skill?: string;
  prompt: string;
  dependsOn?: string[];
  status: "pending" | "in-progress" | "done" | "failed";
}

interface Workflow {
  id: string;
  name: string;
  steps: WorkflowStep[];
  currentStep?: string;
}

// In-memory workflow store (could be persisted to disk)
const workflows = new Map<string, Workflow>();

// Track activation state
let activated = false;

export default function (pi: ExtensionAPI) {
  // Register activation command - this is the ONLY thing registered initially
  pi.registerCommand("workflow-orchestrator", {
    description: "Activate workflow orchestrator (loads /plan, /workflow, spawn-agent tool)",
    handler: async (_args, ctx) => {
      if (activated) {
        ctx.ui.notify("Workflow orchestrator is already active!", "info");
        return;
      }
      
      activateWorkflowOrchestrator(pi);
      activated = true;
      ctx.ui.notify("✓ Workflow orchestrator activated! Commands available: /plan, /workflow", "success");
    },
  });

  // Check if already activated (e.g., on session resume)
  pi.on("session_start", async (event, ctx) => {
    // Check if there's a marker in the session indicating activation
    const entries = ctx.sessionManager.getEntries();
    const hasActivationMarker = entries.some(
      (e: any) => e.type === "custom" && e.customType === "workflow-orchestrator-active"
    );
    
    if (hasActivationMarker && !activated) {
      activateWorkflowOrchestrator(pi);
      activated = true;
      ctx.ui.notify("Workflow orchestrator restored from session", "info");
    }
  });
}

function activateWorkflowOrchestrator(pi: ExtensionAPI) {
  // Register /plan command for plan mode
  pi.registerCommand("plan", {
    description: "Enter plan mode: break a task into steps",
    handler: async (args, ctx) => {
      const task = args.join(" ");
      if (!task) {
        return "Usage: /plan <describe your task>";
      }

      // Ask the model to create a plan
      const planPrompt = `Create a step-by-step plan for: ${task}
      
Break it into clear steps. For each step, specify:
- Step name
- Which skill to use (researcher, architect, builder, code-reviewer, or none)
- Brief description

Format as JSON:
[
  {"name": "step name", "skill": "skill-name", "prompt": "what to do"},
  ...
]`;

      // Store plan in session state or return for user to approve
      return {
        type: "plan",
        content: planPrompt,
        task,
      };
    },
  });

  // Register /workflow command for multi-step execution
  pi.registerCommand("workflow", {
    description: "Run a multi-step workflow",
    handler: async (args, ctx) => {
      const subcommand = args[0];
      const rest = args.slice(1);

      if (subcommand === "list") {
        return `Active workflows: ${Array.from(workflows.keys()).join(", ") || "none"}`;
      }

      if (subcommand === "run" && rest.length > 0) {
        const workflowName = rest.join(" ");
        return `Starting workflow: ${workflowName}\nUse /plan to create a plan first.`;
      }

      return "Usage: /workflow list | /workflow run <name>";
    },
  });

  // Register a tool for spawning sub-agents (research, review, etc.)
  pi.registerTool({
    name: "spawn-agent",
    description: "Spawn a specialized sub-agent for a specific task",
    parameters: {
      type: "object",
      properties: {
        type: {
          type: "string",
          enum: ["researcher", "architect", "builder", "code-reviewer"],
          description: "Type of agent to spawn",
        },
        task: {
          type: "string",
          description: "Task description for the sub-agent",
        },
      },
      required: ["type", "task"],
    },
    execute: async (args, ctx) => {
      const { type, task } = args;

      // In a real implementation, this would:
      // 1. Create a new pi session (via SDK or tmux)
      // 2. Load the appropriate skill
      // 3. Execute the task
      // 4. Return the result

      return `[Sub-agent ${type}] would process: ${task}\n\nTo fully implement, use tmux to spawn: pi -p "/skill:${type} ${task}"`;
    },
  });

  // Event handler: when a skill is loaded, log it
  pi.on("session_start", async (event, ctx) => {
    console.log("Workflow orchestrator active");
  });

  // Register a message renderer for workflow status (shown in TUI)
  pi.registerMessageRenderer("workflow-status", (entry, theme) => {
    if (workflows.size === 0) return null;
    const active = Array.from(workflows.values())[0];
    const current = active.steps.find((s) => s.status === "in-progress");
    const status = current ? `🔄 ${active.name}: ${current.name}` : `📋 ${active.name}`;
    return [`${theme.info(status)}`];
  });

  // Show workflow status in footer when agent is idle
  pi.on("agent_end", async (_event, ctx) => {
    if (workflows.size === 0) {
      ctx.ui.setStatus("workflow", undefined);
    } else {
      const active = Array.from(workflows.values())[0];
      const current = active.steps.find((s) => s.status === "in-progress");
      const status = current ? `🔄 ${active.name}: ${current.name}` : `📋 ${active.name}`;
      ctx.ui.setStatus("workflow", status);
    }
  });

  // Persist activation state
  pi.appendEntry("workflow-orchestrator-active", {
    activated: true,
    timestamp: Date.now(),
  });
}
