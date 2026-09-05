# hAI.WorldIntelMCP Agent Instructions

This document provides instructions for AI agents interacting with the **World-Intel-MCP** server — 120 MCP tools for real-time global intelligence across 30+ domains (markets, SEC filings, conflict, military, cyber, climate, news, geospatial and more). All data comes from free, public APIs: no external API keys are required.

## 1. Connection & Transport

* **Primary endpoint (MCP clients):** Streamable HTTP at `http://<host>:8030/mcp` (via supergateway)
* **Transport behavior:** stateless — every JSON-RPC POST is independent, no session or sticky connection required. Multiple clients can connect in parallel.
* **Protocol flow:** `initialize` → `tools/list` → `tools/call` (standard MCP JSON-RPC over HTTP POST).
* **Optional OpenAPI mode:** if the operator enabled `ENABLE_MCPO=true`, every tool is also exposed as a REST endpoint on `http://<host>:8031` — discover them via `http://<host>:8031/openapi.json` (Swagger UI at `/docs`). In this mode the endpoint is protected by a Bearer API key (`MCP_API_KEY`) if configured.
* **Human dashboard (not for agents):** `http://<host>:8501` — SSE ops-center with live feeds.

## 2. Authentication

* The Streamable HTTP endpoint `/mcp` has **no built-in authentication** by default. It is intended for trusted networks (LAN) or behind a VPN / Cloudflare Access.
* If the operator set `MCP_API_KEY` and enabled OpenAPI mode (`:8031`), include the key in the `Authorization` header as a Bearer token:

**Example:** `Authorization: Bearer YOUR_API_KEY`

## 3. Tool Discovery & Naming

* All tools follow the `intel_*` naming convention (e.g. `intel_earthquakes`, `intel_market_quotes`, `intel_acled_events`).
* Discover tools and their exact parameter schemas via `tools/list` (MCP) or `GET /openapi.json` (OpenAPI mode). **Always read the tool description/schema before calling — parameter names are authoritative there.**

## 4. Available Tool Domains

| Domain | Example Tools | What agents use it for |
|---|---|---|
| 📈 Financial Markets | `intel_market_quotes`, `intel_crypto_quotes`, `intel_sector_heatmap`, `intel_commodity_quotes`, `intel_macro_signals` | Stock indices, crypto, commodities, sector performance |
| 💱 Forex & Currency | `intel_forex_rates`, `intel_forex_timeseries`, `intel_major_crosses` | FX rates, trends, major pairs |
| 💼 Bonds, Earnings & SEC | `intel_yield_curve`, `intel_sec_filings`, `intel_company_filings`, `intel_recent_8k`, `intel_earnings_calendar` | Yield curve, EDGAR full-text search, 8-K material events |
| 🏦 Macro & Central Banks | `intel_fred_series`, `intel_world_bank_indicators`, `intel_central_bank_rates`, `intel_macro_composite` | GDP/CPI data, policy rates, weighted market verdict |
| 🌋 Natural Disasters & Climate | `intel_earthquakes`, `intel_wildfires`, `intel_disaster_alerts`, `intel_environmental_events` | USGS quakes, satellite fire hotspots, GDACS alerts |
| ⚔️ Conflict & Security | `intel_acled_events`, `intel_ucdp_events`, `intel_unrest_events`, `intel_humanitarian_summary` | Armed conflict events, social unrest, crisis data |
| 🛩️ Military & Defense | `intel_military_flights`, `intel_theater_posture`, `intel_military_surge`, `intel_aircraft_details`, `intel_usni_fleet` | Military aircraft, theater posture, surge anomalies |
| 🌐 Infrastructure & Maritime | Cloudflare Radar, submarine cables, NGA warnings, vessel/flight snapshots | Internet disruptions, cable outages, navigation warnings |
| 📰 News & Media | RSS-based news tools, GDELT queries, trending keywords | Headlines, media monitoring, keyword spikes |
| 🧠 Intelligence Analysis & Synthesis | signal convergence, focal points, instability index, escalation scoring, world brief | Cross-domain synthesis when multiple domains matter at once |
| 🗺️ Geospatial | military bases, ports, pipelines, nuclear facilities, datacenters | Reference layers for spatial context |
| 🦠 Cyber & Health | URLhaus, Feodotracker, CISA KEV, WHO/ProMED outbreak tools | Threat feeds, disease outbreaks |
| 🤖 AI & Technology | arXiv papers, HuggingFace models, Hacker News, GitHub trending | Tech landscape monitoring |
| 🔎 Vector Search (optional) | semantic search, similarity, timeline, stats | Natural-language queries over accumulated intelligence (needs Qdrant + `ENABLE_COLLECTOR=true`) |
| 📡 AOI Geofences & Briefings | define/list/delete AOIs, cited multi-domain brief for a zone, daily digest | Monitor a user-defined area of interest with cited briefings |

**Total: 120 tools** — the authoritative list with parameter schemas is always available via `tools/list`.

## 5. Usage Guidelines

* **Prefer the narrow tool first.** Domain tools (`intel_earthquakes`, `intel_market_quotes`) are faster and cheaper than broad synthesis tools (world brief, situation brief). Use synthesis tools when a question genuinely spans multiple domains.
* **Caching:** results are cached in SQLite with TTL. Repeated identical calls may return cached data — this is intentional and reduces load on public sources.
* **Circuit breakers:** each source has a per-source breaker. After 3 consecutive failures a source is tripped for ~5 minutes and tools return stale-fallback data or partial results. Handle partial data gracefully.
* **Be gentle with rate limits.** All sources are public APIs. Do not call the same tool in a tight loop — rely on the cache and space out requests.
* **Citations:** briefing/digest tools return inline `[n]` citations. When relaying results to users, keep the citations so claims stay verifiable.
* **Geofences/AOIs:** user-defined zones persist on the server (data volume). Create, list and reuse named AOIs instead of redefining them per request.
* **Vector search:** only meaningful if the operator runs the `vector` profile (Qdrant) and the collector daemon. If semantic queries return empty, the store likely has no accumulated data yet.

## 6. Examples

Initialize (curl):

```bash
curl -s http://<host>:8030/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"my-agent","version":"1.0"}}}'
```

List all tools:

```json
{"jsonrpc":"2.0","id":2,"method":"tools/list"}
```

Call a tool (parameter names are authoritative via `tools/list`):

```json
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"intel_earthquakes","arguments":{"min_magnitude":5.0}}}
```

## 7. Health & Diagnostics

* Operators can check cache and circuit-breaker health via the CLI: `docker exec -it world-intel-mcp intel status`
* The dashboard on `:8501` shows per-source breaker health for humans.

## 8. Security Notes

* Treat `/mcp` as trusted-network only (no built-in auth). For external exposure, the operator should front it with Cloudflare Access or similar.
* All data is public OSINT — never invent additional “classified” framing for results.
* Do not log or persist large result payloads unnecessarily; summarize and cite instead.
