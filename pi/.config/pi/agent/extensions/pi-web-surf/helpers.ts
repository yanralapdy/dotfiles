// pi-surf helpers — zero-dependency, pure functions, testable
import { execFileSync } from "node:child_process";

/** Format ketch search JSON results into readable markdown. */
export function formatResults(
  data: unknown,
  query: string,
): string {
  if (!Array.isArray(data) || data.length === 0) {
    return `No results found for "${query}".`;
  }
  return data
    .map(
      (r: any, i: number) =>
        `${i + 1}. **${r.title || "Untitled"}**\n   ${r.url || "(no url)"}\n   ${r.description || ""}`,
    )
    .join("\n\n");
}

/** Format ketch scrape JSON result into markdown. */
export function formatScrape(data: unknown): string {
  const items = Array.isArray(data) ? data : [data];
  return items
    .map((d: any) => `## ${d.title || d.url || "Untitled"}\n\n${d.markdown || JSON.stringify(d)}`)
    .join("\n\n---\n\n");
}

/**
 * Check if ketch is installed and configured.
 * Returns null if OK, or an error string.
 */
export function checkKetch(): string | null {
  try {
    execFileSync("ketch", ["--version"], {
      encoding: "utf-8",
      timeout: 5_000,
      stdio: "pipe",
    });
  } catch {
    return "ketch is not installed. Install it: brew install 1broseidon/tap/ketch";
  }

  try {
    const raw = execFileSync("ketch", ["config"], {
      encoding: "utf-8",
      timeout: 5_000,
      stdio: "pipe",
    });
    const cfg = JSON.parse(raw);
    const backend = cfg.backend || "";
    if (backend === "brave" && !cfg.brave_api_key) {
      return "ketch backend is 'brave' but no API key is set. Run: ketch config set backend ddg";
    }
  } catch {
    // config fetch failed — let the actual search call surface the error
  }

  return null;
}

/** Run ketch with given args, return parsed JSON or error. */
export function runKetch(
  args: string[],
): { ok: true; data: unknown } | { ok: false; error: string } {
  try {
    const raw = execFileSync("ketch", args, {
      encoding: "utf-8",
      timeout: 30_000,
      maxBuffer: 512 * 1024,
      stdio: ["ignore", "pipe", "pipe"],
    });
    return { ok: true, data: JSON.parse(raw.trim()) };
  } catch (e: any) {
    const msg = e.stderr
      ? typeof e.stderr === "string"
        ? e.stderr
        : e.stderr.toString()
      : e.message;
    return { ok: false, error: msg.trim() };
  }
}
