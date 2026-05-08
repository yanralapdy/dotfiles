/**
 * Plan Mode Extension (JavaScript version)
 * Read-only exploration mode for safe code analysis.
 */

import { extractTodoItems, isSafeCommand, markCompletedSteps } from "./utils.js";

export default function planModeExtension(pi) {
    let planModeEnabled = false;
    let executionMode = false;
    let todoItems = [];

    // Tools available in different modes
    const PLAN_MODE_TOOLS = ["read", "bash", "grep", "find", "ls", "questionnaire"];
    const NORMAL_MODE_TOOLS = ["read", "bash", "edit", "write"];

    function updateStatus(ctx) {
        // Footer status
        if (executionMode && todoItems.length > 0) {
            const completed = todoItems.filter(t => t.completed).length;
            ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg("accent", `📋 ${completed}/${todoItems.length}`));
        } else if (planModeEnabled) {
            ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg("warning", "⏸ plan"));
        } else {
            ctx.ui.setStatus("plan-mode", undefined);
        }

        // Widget showing todo list
        if (executionMode && todoItems.length > 0) {
            const lines = todoItems.map((item) => {
                if (item.completed) {
                    return ctx.ui.theme.fg("success", "☑ ") + ctx.ui.theme.fg("muted", ctx.ui.theme.strikethrough(item.text));
                }
                return `${ctx.ui.theme.fg("muted", "☐ ")}${item.text}`;
            });
            ctx.ui.setWidget("plan-todos", lines);
        } else {
            ctx.ui.setWidget("plan-todos", undefined);
        }
    }

    function togglePlanMode(ctx) {
        planModeEnabled = !planModeEnabled;
        executionMode = false;
        todoItems = [];

        if (planModeEnabled) {
            pi.setActiveTools(PLAN_MODE_TOOLS);
            ctx.ui.notify(`Plan mode enabled. Tools: ${PLAN_MODE_TOOLS.join(", ")}`);
        } else {
            pi.setActiveTools(NORMAL_MODE_TOOLS);
            ctx.ui.notify("Plan mode disabled. Full access restored.");
        }
        updateStatus(ctx);
    }

    // Register /plan command
    pi.registerCommand("plan", {
        description: "Toggle plan mode (read-only exploration)",
        handler: async (_args, ctx) => togglePlanMode(ctx),
    });

    // Register /todos command
    pi.registerCommand("todos", {
        description: "Show current plan todo list",
        handler: async (_args, ctx) => {
            if (todoItems.length === 0) {
                ctx.ui.notify("No todos. Create a plan first with /plan", "info");
                return;
            }
            const list = todoItems.map((item, i) => `${i + 1}. ${item.completed ? "✓" : "○"} ${item.text}`).join("\n");
            ctx.ui.notify(`Plan Progress:\n${list}`, "info");
        },
    });

    // Block destructive bash commands in plan mode
    pi.on("tool_call", async (event) => {
        if (!planModeEnabled || event.toolName !== "bash") return;

        const command = event.input.command;
        if (!isSafeCommand(command)) {
            return {
                block: true,
                reason: `Plan mode: command blocked (not allowlisted). Use /plan to disable plan mode first.\nCommand: ${command}`,
            };
        }
    });
}
