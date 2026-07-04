// pi-surf: internet search + web scraping via ketch CLI
// Pi extension — replaces built-in internet_search with ketch-powered search + scrape
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { formatResults, formatScrape, runKetch } from "./helpers";

type ToolResult = { content: { type: "text"; text: string }[]; details: Record<string, unknown> };

// ── extension entry ────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // ── internet_search ──────────────────────────────────────────────

  pi.registerTool({
    name: "internet_search",
    label: "Internet Search",
    description:
      "Search the internet for real-time information, news, facts, and current events using ketch (DuckDuckGo by default). Returns ranked results with title, URL, and description.",
    promptSnippet: "Search the internet for real-time information using ketch",
    promptGuidelines: [
      "Use internet_search when you need current information, facts, news, or real-time data.",
      "Use internet_search before answering questions about recent events, technologies, or APIs.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "The search query to look up on the internet" }),
      limit: Type.Optional(
        Type.Number({ description: "Maximum number of results (default 5, max 10)" }),
      ),
    }),
    async execute(
      _toolCallId: string,
      params: { query: string; limit?: number },
      _signal: AbortSignal | undefined,
      _onUpdate: ((update: any) => void) | undefined,
      _ctx: any,
    ): Promise<ToolResult> {
      const limit = Math.min(params.limit ?? 5, 10);
      const result = runKetch(["search", params.query, "--limit", String(limit), "--json"]);

      if (!result.ok) {
        return {
          content: [{ type: "text", text: `Search failed: ${result.error}` }],
          details: { error: result.error },
        };
      }

      return {
        content: [{ type: "text", text: formatResults(result.data, params.query) }],
        details: { raw: result.data },
      };
    },
  });

  // ── ketch_scrape ─────────────────────────────────────────────────

  pi.registerTool({
    name: "internet_scrape",
    label: "Scrape URL",
    description:
      "Fetch a URL and extract clean markdown content. Use this to read the full content of a web page found via internet_search.",
    promptSnippet: "Scrape a URL to clean markdown content",
    promptGuidelines: [
      "Use internet_scrape to fetch and read the full content of a web page found via internet_search.",
      "Prefer internet_scrape over opening URLs manually.",
    ],
    parameters: Type.Object({
      url: Type.String({ description: "URL to scrape and extract content from" }),
      raw: Type.Optional(
        Type.Boolean({ description: "Return raw HTML instead of markdown (default false)" }),
      ),
      maxChars: Type.Optional(
        Type.Number({ description: "Truncate output to N characters (0 = no limit)" }),
      ),
    }),
    async execute(
      _toolCallId: string,
      params: { url: string; raw?: boolean; maxChars?: number },
      _signal: AbortSignal | undefined,
      _onUpdate: ((update: any) => void) | undefined,
      _ctx: any,
    ): Promise<ToolResult> {
      const args = ["scrape", params.url, "--json"];
      if (params.raw) args.push("--raw");
      if (params.maxChars && params.maxChars > 0) {
        args.push("--max-chars", String(params.maxChars));
      }

      const result = runKetch(args);

      if (!result.ok) {
        return {
          content: [{ type: "text", text: `Scrape failed: ${result.error}` }],
          details: { error: result.error },
        };
      }

      return {
        content: [{ type: "text", text: formatScrape(result.data) }],
        details: { raw: result.data },
      };
    },
  });
}
