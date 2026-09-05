# 🌍 hAI.WorldIntelMCP

> ### 120 MCP-Tools für Echtzeit-Global-Intelligence
> 📈 Märkte · ⚔️ Konflikte · 🛩️ Militär · 🌋 Katastrophen · 🦠 Cyber · 📰 News · 🗺️ Geospatial

[![Build and publish Docker image](https://github.com/jbkunama1/hAI.WorldIntelMCP/actions/workflows/docker-image.yml/badge.svg)](https://github.com/jbkunama1/hAI.WorldIntelMCP/actions/workflows/docker-image.yml)
[![TruffleHog](https://github.com/jbkunama1/hAI.WorldIntelMCP/actions/workflows/trufflehog.yml/badge.svg)](https://github.com/jbkunama1/hAI.WorldIntelMCP/actions/workflows/trufflehog.yml)
[![Docker Image](https://img.shields.io/badge/ghcr.io-image-2496ED?logo=docker&logoColor=white)](https://github.com/jbkunama1/hAI.WorldIntelMCP/pkgs/container/hai.worldintelmcp)
[![GitHub Pages](https://img.shields.io/badge/GitHub-Pages-222222?logo=githubpages&logoColor=white)](https://jbkunama1.github.io/hAI.WorldIntelMCP/)
[![MCP](https://img.shields.io/badge/MCP-Compatible-blue)](https://modelcontextprotocol.io)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11%2B-3776AB?logo=python&logoColor=white)](https://python.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**World-Intel-MCP** ([marc-shade/world-intel-mcp](https://github.com/marc-shade/world-intel-mcp)) als **Portainer-Stack** 🐳 — der stdio-MCP-Server wird via **supergateway** als **Streamable-HTTP-Endpoint** (`/mcp`) exponiert, das **Ops-Center-Dashboard** läuft direkt mit im Container, und ein optionaler **Qdrant-Vektor-Store** ermöglicht semantische Suche über angesammelte Intelligence. Zusätzlich optional: **OpenAPI-Endpoint** via mcpo.

✅ Alle Datenquellen sind **kostenlose, öffentliche APIs** — keine API-Keys, keine Subscriptions. 🎉

🌐 **Projektseite:** <https://jbkunama1.github.io/hAI.WorldIntelMCP/>

---

## 📑 Inhaltsverzeichnis

- [🌍 Überblick](#-überblick)
- [✨ Domänen & Tools](#-domänen--tools)
- [🚀 Installation](#-installation)
- [🔧 Env-Variablen & Ports](#-env-variablen--ports)
- [🔌 MCP-Clients anbinden](#-mcp-clients-anbinden)
- [💬 Beispiel-Abfragen](#-beispiel-abfragen)
- [🗃 Qdrant & Collector](#-qdrant--collector)
- [📟 Dashboard & CLI](#-dashboard--cli)
- [🧭 Troubleshooting](#-troubleshooting)
- [🔐 Sicherheit](#-sicherheit)
- [📄 Lizenz & Credits](#-lizenz--credits)

---

## 🌍 Überblick

```text
🤖 MCP client / AnythingMCP / Agenten
        │
        │  🔌 Streamable HTTP (POST /mcp, via supergateway)
        ▼
🌍 world-intel-mcp :8030/mcp   ← 120 MCP-Tools (stdio) via supergateway
        │
        │  Fetcher → CircuitBreaker → Cache (SQLite) → 🗃 optional Qdrant
        ▼
46+ öffentliche Quellen: Yahoo Finance · SEC EDGAR · FRED · USGS · NASA FIRMS ·
ACLED · GDELT · adsb.lol · OpenSky · Cloudflare Radar · WHO · NOAA · …

📟 Ops-Center-Dashboard :8501   ← SSE-Live-Feeds, Leaflet-Map, Breaker-Health
🔄 Collector (optional)         ← füllt den Qdrant-Store im 5-Min-Intervall
📘 OpenAPI (optional) :8031     ← mcpo: Tools als REST-Endpunkte (ENABLE_MCPO)
```

| 🧩 Baustein | Beschreibung |
|---|---|
| 🐳 **Dockerfile** | Klont das Upstream-Projekt zur Build-Zeit (per `WORLD_INTEL_REF` pinbar), installiert `.[dashboard,vector]` + supergateway & mcpo |
| 🔌 **supergateway** | Exponiert den stdio-Server als **Streamable HTTP** auf `:8030/mcp` — stateless, beliebig viele Clients parallel |
| 📘 **mcpo (optional)** | OpenAPI-Endpoint auf `:8031` (per `MCPO_PORT` frei wählbar), schützbar per `MCP_API_KEY` |
| 📄 **instructions.md** | Agent-Anleitung: Verbindung, Tool-Domains, Usage-Guidelines, Beispiel-Fragen — damit Agenten wissen, was der MCP kann |
| 📦 **Portainer-Stack** | `docker-compose.yml` — deploybar direkt aus dem Repository, **alle Ports per Env konfigurierbar** |
| 🚀 **GHCR-Image** | GitHub Actions pusht nach `ghcr.io/jbkunama1/hai.worldintelmcp:latest` |
| 🐖 **TruffleHog-Workflow** | Secret-Scan bei jedem Push/PR |
| 🗃 **Qdrant (optional)** | Semantische Suche über angesammelte Intelligence (Profil `vector`) |

---

## ✨ Domänen & Tools

| Domäne | 🛠️ Tools | Quellen (Beispiele) |
|---|---:|---|
| 📈 Finanzmärkte & Forex | 12 | Yahoo Finance, CoinGecko, ECB/Frankfurter |
| 💼 Bonds, Earnings & SEC | 7 | FRED, SEC EDGAR (Full-Text, 8-K) |
| 🏦 Makro & Notenbanken | 8 | FRED, World Bank, 15 Zentralbanken |
| ⚔️ Konflikte & Sicherheit | 4 | ACLED, UCDP, Unrest-Detection |
| 🛩️ Militär & Verteidigung | 6 | adsb.lol, OpenSky, hexdb.io, Surge-Detection |
| 🌋 Naturkatastrophen & Klima | 7 | USGS, NASA FIRMS/EONET, GDACS, Open-Meteo |
| 🌐 Infrastruktur & Maritime | 6 | Cloudflare Radar, Seekabel, NGA, FAA |
| 📰 News & Medien | 3 | 119 RSS-Feeds (4-Tier), GDELT, Trends |
| 🧠 Analyse & Synthese | 12+ | Signal-Konvergenz, Instabilitätsindex, Eskalation |
| 🗺️ Geospatial | 11 | Basen, Häfen, Pipelines, Kernkraft, Rechenzentren |
| 🦠 Cyber & Health | 2 | URLhaus, CISA KEV, WHO DON, ProMED |
| 🤖 KI & Technologie | 4 | arXiv, HuggingFace, Hacker News, GitHub Trending |
| 🔎 Vektor-Suche (Qdrant) | 5 | semantische Suche, Timeline, Stats |
| 📡 AOI-Geofences & Briefings | 7+ | eigene Zonen, zitierte Briefings, Daily Digest |

**Gesamt: 120 Tools** über 30+ Domänen — Details im [Upstream-README](https://github.com/marc-shade/world-intel-mcp). 🔗

---

## 🚀 Installation

### 🥇 Option A — Portainer (empfohlen)

1. **Stacks → Add stack → Repository** 📦
2. Repository-URL: `https://github.com/jbkunama1/hAI.WorldIntelMCP.git`
3. Compose-Pfad: `docker-compose.yml`, Branch: `main` 🌿
4. Umgebungsvariablen setzen (siehe [🔧 Env-Variablen & Ports](#-env-variablen--ports)) — z. B. `ENABLE_MCPO=true` für den OpenAPI-Endpoint
5. Docker-Netzwerk (falls nicht vorhanden):

```bash
docker network create highfishNetwork
```

6. **Deploy** 🚀 — das Image `ghcr.io/jbkunama1/hai.worldintelmcp:latest` wird automatisch gepullt.

### 🥈 Option B — Docker Compose

```bash
git clone https://github.com/jbkunama1/hAI.WorldIntelMCP.git
cd hAI.WorldIntelMCP
cp .env.example .env   # Werte anpassen

docker compose up -d
```

### 🥉 Option C — docker run

```bash
docker run -d --name world-intel-mcp \
  -p 8030:8030 -p 8501:8501 \
  -v ./data:/data \
  ghcr.io/jbkunama1/hai.worldintelmcp:latest
```

### 🔨 Selbst bauen (Upstream-Version pinnen)

```bash
docker build --build-arg WORLD_INTEL_REF=v0.3.0 -t hai.worldintelmcp .
```

Default ist `main` — mit `WORLD_INTEL_REF` auf jedes Tag des Upstream-Repos pinbar.

---

## 🔧 Env-Variablen & Ports

💡 **Port-Variablen steuern Host- und Container-Port gleichzeitig** — beim Ändern einfach den Stack neu deployen, die Compose muss nicht mehr angefasst werden.

| Variable | Pflicht | Default | Zweck |
|---|---|---|---|
| `MCP_HTTP_PORT` | – | `8030` | 🔌 Streamable-HTTP-Endpoint `/mcp` (supergateway) |
| `MCPO_PORT` | – | `8031` | 📘 Optionaler OpenAPI-Endpoint (mcpo) |
| `DASHBOARD_PORT` | – | `8501` | 📟 Ops-Center-Dashboard (SSE) |
| `MCP_API_KEY` | – | *(leer)* | 🔑 API-Key für den mcpo-OpenAPI-Endpoint (leer = keine Auth) |
| `ENABLE_MCPO` | – | `false` | 📘 mcpo-OpenAPI-Endpoint zusätzlich starten |
| `ENABLE_COLLECTOR` | – | `false` | 🔄 Collector-Daemon: füllt Qdrant im 5-Min-Intervall |
| `QDRANT_URL` | – | *(leer)* | 🗃 z. B. `http://world-intel-qdrant:6333` (Profil `vector`) |
| `TZ` | – | `Europe/Berlin` | 🕐 Zeitzone |

### 📘 Beispiel: mcpo auf eigenem Port mit API-Key

```text
ENABLE_MCPO=true
MCPO_PORT=9031
MCP_API_KEY=dein-starker-key   # z. B. openssl rand -hex 32
```

→ OpenAPI-Doku: `http://<host>:9031/docs` · Beschreibung: `http://<host>:9031/openapi.json`

---

## 🔌 MCP-Clients anbinden

### 🥇 Streamable HTTP (für MCP-Clients)

supergateway exponiert den Server auf **`http://<host>:8030/mcp`** — stateless, mehrere Clients parallel:

```json
{
  "mcpServers": {
    "world-intel": {
      "name": "World Intel MCP",
      "type": "streamable",
      "url": "http://<host>:8030/mcp",
      "enabled": true
    }
  }
}
```

Schnelltest per curl:

```bash
curl -s http://<host>:8030/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"curl","version":"0"}}}'
```

### 📘 OpenAPI (optional, für Agenten/OpenAPI-Clients)

Mit `ENABLE_MCPO=true` startet zusätzlich **mcpo** auf `:8031` (per `MCPO_PORT` frei wählbar) — jeder der 120 Tools wird als eigener REST-Endpunkt exponiert:

- Doku: `http://<host>:8031/docs`
- Beschreibung: `http://<host>:8031/openapi.json` — hier zeigen AnythingMCP & Co. hin
- 🔑 Schützbar per `MCP_API_KEY` (Clients senden `Authorization: Bearer <KEY>`)

⚠️ Der Streamable-Endpoint `/mcp` hat **keine eigene Auth** — nur im LAN oder hinter Cloudflare Access/Tunnel betreiben.

---

## 💬 Beispiel-Abfragen

Was Agenten (und du) den Server fragen können — Frage → empfohlene Tools:

| 💬 Frage | 🛠️ Empfohlene Tools |
|---|---|
| „Was passiert gerade in der Welt?" | Daily Digest / World Brief (zitierte Gesamtübersicht über alle Domänen) |
| „Wie steht der Markt heute?" | `intel_market_quotes`, `intel_macro_signals`, `intel_macro_composite` |
| „Was läuft militärisch im Mittelmeer / Nahen Osten?" | `intel_theater_posture`, `intel_military_flights`, `intel_military_surge` |
| „Gab es heute starke Erdbeben oder Waldbrände?" | `intel_earthquakes` (min. Magnitude setzen), `intel_wildfires` |
| „Gibt es Eskalationssignale in <Region>?" | Escalation-Scoring, Signal-Konvergenz, `intel_acled_events` |
| „Welche Cyber-Bedrohungen sind gerade aktiv?" | URLhaus, Feodotracker, CISA KEV |
| „Was passiert rund um meine Region / mein Zuhause?" | AOI-Geofence einmal definieren, dann zitierten AOI-Brief abrufen |
| „Was ist neu bei Firma X (Kurs, SEC, News)?" | `intel_company_profile`, `intel_company_filings`, `intel_recent_8k` |

Die vollständige Agenten-Anleitung mit Usage-Guidelines steht in [instructions.md](instructions.md). 🤖

---

## 🗃 Qdrant & Collector

Semantische Suche (z. B. *„Militäraktivität nahe Taiwan"*) über angesammelte Intelligence:

1. Stack mit Profil `vector` deployen — lokal `docker compose --profile vector up -d`, in Portainer beim Redeploy die Compose-Profile `vector` setzen
2. `QDRANT_URL=http://world-intel-qdrant:6333` setzen
3. `ENABLE_COLLECTOR=true` — der Collector fetched alle 46 Quellen parallel und befällt den Store

Qdrant-Daten liegen im Volume `./data/qdrant`. 💾

---

## 📟 Dashboard & CLI

**🖥️ Ops-Center-Dashboard:** `http://<host>:8501` — Leaflet-Map mit umschaltbaren Layern (Quakes, Military, Conflict, Fires, Convergence, Nuclear, Infrastructure), 47 Live-SSE-Feeds, HUD-Bar, Circuit-Breaker-Health pro Quelle.

**🧰 CLI im Container:**

```bash
docker exec -it world-intel-mcp intel markets
docker exec -it world-intel-mcp intel earthquakes --min-mag 5.0
docker exec -it world-intel-mcp intel status
```

---

## 🧭 Troubleshooting

| Symptom | Lösung |
|---|---|
| 🔌 `Streamable HTTP error: {"detail":"Not Found"}` bzw. `POST /mcp → 404` | Client POSTet auf einen Pfad ohne MCP-Endpoint. Ursache: ältere Image-Version exponierte nur mcpo (OpenAPI). **Image neu pullen** (`docker pull ghcr.io/jbkunama1/hai.worldintelmcp:latest`) und Client-URL auf `http://<host>:8030/mcp` setzen |
| ❌ Image-Pull schlägt fehl | GHCR-Paket im Repo (Packages) auf Public setzen oder per `docker login ghcr.io` einloggen |
| 📟 Dashboard nicht erreichbar | Port frei? `DASHBOARD_PORT` prüfen, Container-Logs ansehen |
| 🔌 /mcp liefert Timeout beim Erstconnect | Erster Start initialisiert Quellen/Caches — kurz warten und erneut versuchen |
| 🐳 Port schon belegt | Env-Variable (`MCP_HTTP_PORT`/`MCPO_PORT`/`DASHBOARD_PORT`) ändern und Stack neu deployen — Host- und Container-Port folgen automatisch, keine Compose-Anpassung nötig |
| 🗃 Qdrant-Verbindung fehlschlägt | Profil `vector` aktiv? `QDRANT_URL` korrekt? Beide Container im `highfishNetwork`? |

---

## 🔐 Sicherheit

- 🔒 Der Streamable-Endpoint `/mcp` hat **keine eigene Auth** — nur im LAN oder hinter VPN/HTTPS bzw. Cloudflare Access betreiben.
- 🔑 `MCP_API_KEY` schützt den optionalen mcpo-OpenAPI-Endpoint (Bearer-Token).
- 🔒 Das Dashboard hat keine Auth — gleiche Regel wie oben.
- 🐖 TruffleHog-Workflow prüft automatisch auf versehentlich eingecheckte Secrets.

---

## 📄 Lizenz & Credits

- 📄 **MIT** — siehe [LICENSE](LICENSE)
- 🌍 Upstream: [marc-shade/world-intel-mcp](https://github.com/marc-shade/world-intel-mcp) (MIT) — 120 Tools, Dashboard, CLI, Qdrant-Vektor-Store
- 🔌 MCP-zu-HTTP-Bridge: [supergateway](https://github.com/supercorp-ai/supergateway) (Streamable HTTP) & [mcpo](https://github.com/evalstate/mcp-adapter) (OpenAPI)

---

☕ **hAI.WorldIntelMCP** · Teil des highfishNetwork-Stacks
