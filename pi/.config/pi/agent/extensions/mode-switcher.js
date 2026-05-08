/**
 * Mode Switcher Extension
 * 
 * Provides /mode command to switch between different personas/modes:
 * - /mode researcher - Switch to researcher mode
 * - /mode plan - Switch to planning mode  
 * - /mode architect - Switch to architect mode
 * - /mode builder - Switch to builder mode
 * - /mode code-reviewer - Switch to code reviewer mode
 */

export default function (pi) {
    pi.registerCommand("mode", {
        description: "Switch between modes (researcher, plan, architect, builder, code-reviewer). Usage: /mode <name>",
        getArgumentCompletions: (prefix) => {
            const modes = ["researcher", "plan", "architect", "builder", "code-reviewer"];
            const filtered = modes.filter(m => m.startsWith(prefix.toLowerCase()));
            return filtered.length > 0 ? filtered.map(m => ({ value: m, label: m })) : null;
        },
        handler: async (args, ctx) => {
            const mode = args.trim().toLowerCase();
            
            if (!mode) {
                ctx.ui.notify("Available modes: researcher, plan, architect, builder, code-reviewer\nUsage: /mode <name>", "info");
                return;
            }
            
            const availableModes = ["researcher", "plan", "architect", "builder", "code-reviewer"];
            
            if (!availableModes.includes(mode)) {
                ctx.ui.notify(`Unknown mode: ${mode}\nAvailable modes: ${availableModes.join(", ")}`, "error");
                return;
            }
            
            // Map mode to the corresponding command
            const modeToCommand = {
                "researcher": "/researcher",
                "plan": "/plan",
                "architect": "/architect",
                "builder": "/builder",
                "code-reviewer": "/code-reviewer"
            };
            
            const command = modeToCommand[mode];
            ctx.ui.notify(`Switching to ${mode} mode...`, "info");
            
            // The skill commands should be invoked by the user directly
            // We'll just show a helpful message
            ctx.ui.notify(`Use ${command} to activate ${mode} mode`, "info");
        },
    });
}
