import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function (pi: ExtensionAPI) {
  // Register internet search tool
  pi.registerTool({
    name: "internet_search",
    label: "Internet Search",
    description: "Search the internet for real-time information, news, facts, and current events using DuckDuckGo.",
    promptSnippet: "Search the internet for up-to-date information",
    promptGuidelines: [
      "Use internet_search when the user asks for current information, news, or facts that may not be in your training data.",
      "Use internet_search for real-time data like weather, stock prices, or breaking news.",
      "Prefer internet_search over your knowledge when the query explicitly asks for 'latest' or 'current' information.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "The search query to look up on the internet" }),
    }),
    
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const query = params.query;
      
      // Send progress update
      onUpdate?.({
        content: [{ type: "text", text: `Searching for "${query}"...` }],
      });

      try {
        // DuckDuckGo Instant Answer API (free, no API key required)
        const apiUrl = new URL("https://api.duckduckgo.com/");
        apiUrl.searchParams.set("q", query);
        apiUrl.searchParams.set("format", "json");
        apiUrl.searchParams.set("no_html", "1");
        apiUrl.searchParams.set("skip_disambig", "1");

        const response = await fetch(apiUrl.toString(), {
          signal: ctx.signal, // Respect abort signals
          headers: {
            "User-Agent": "Pi-Internet-Search-Extension/1.0",
          },
        });

        if (!response.ok) {
          throw new Error(`Search API returned ${response.status}: ${response.statusText}`);
        }

        const data = await response.json() as {
          AbstractText?: string;
          AbstractURL?: string;
          Answer?: string;
          RelatedTopics?: Array<{
            Text?: string;
            FirstURL?: string;
          }>;
          Results?: Array<{
            Text?: string;
            FirstURL?: string;
          }>;
        };

        // Build result text
        const resultParts: string[] = [];

        // Answer (if available)
        if (data.Answer) {
          resultParts.push(`Answer: ${data.Answer}`);
        }

        // Abstract
        if (data.AbstractText) {
          resultParts.push(`Abstract: ${data.AbstractText}`);
          if (data.AbstractURL) {
            resultParts.push(`Source: ${data.AbstractURL}`);
          }
        }

        // Related topics (top 5)
        if (data.RelatedTopics && data.RelatedTopics.length > 0) {
          resultParts.push("\nRelated Topics:");
          data.RelatedTopics.slice(0, 5).forEach((topic, index) => {
            if (topic.Text) {
              const url = topic.FirstURL ? ` (${topic.FirstURL})` : "";
              resultParts.push(`${index + 1}. ${topic.Text}${url}`);
            }
          });
        }

        // Additional results (top 3)
        if (data.Results && data.Results.length > 0) {
          resultParts.push("\nAdditional Results:");
          data.Results.slice(0, 3).forEach((result, index) => {
            if (result.Text) {
              const url = result.FirstURL ? ` (${result.FirstURL})` : "";
              resultParts.push(`${index + 1}. ${result.Text}${url}`);
            }
          });
        }

        const resultText = resultParts.length > 0 
          ? resultParts.join("\n") 
          : "No results found for your query.";

        return {
          content: [{ type: "text", text: resultText }],
          details: {
            query,
            hasAnswer: !!data.Answer,
            hasAbstract: !!data.AbstractText,
            relatedTopicsCount: data.RelatedTopics?.length || 0,
          },
        };

      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        
        // Check if it was an abort
        if (error instanceof DOMException && error.name === "AbortError") {
          return {
            content: [{ type: "text", text: "Search cancelled by user." }],
            details: { query, aborted: true },
          };
        }

        return {
          content: [{ type: "text", text: `Search error: ${errorMessage}` }],
          isError: true,
          details: { query, error: errorMessage },
        };
      }
    },
  });

  // Optional: Register a command to test the search
  pi.registerCommand("search", {
    description: "Test internet search directly",
    handler: async (args, ctx) => {
      if (!args) {
        ctx.ui.notify("Usage: /search <query>", "warning");
        return;
      }
      
      ctx.ui.notify(`Searching for: ${args}`, "info");
      
      // The tool will be called by the agent, but for direct testing:
      pi.sendUserMessage(`Search for: ${args}`, { deliverAs: "followUp" });
    },
  });
}
