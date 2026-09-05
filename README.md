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

**World-Intel-MCP** ([marc-shade/world-intel-mcp](https://github.com/marc-shade/world-intel-mcp)) als **Portainer-Stack** 🐳 — der stdio-MCP-Server wird via **mcpo** als HTTP/OpenAPI-Endpoint exponiert, das **Ops-Center-Dashboard** läuft direkt mit im Container, und ein optionaler **Qdrant-Vektor-Store** ermöglicht semantische Suche über angesammelte Intelligence.

✅ Alle Datenquellen sind **kostenlose, öffentliche APIs** — keine API-Keys, keine Subscriptions. 🎉

🌐 **Projektseite:** <https://jbkunama1.github.io/hAI.WorldIntelMCP/>

---

## 📑 Inhaltsverzeichnis

- [🌍 Überblick](#-überblick)
- [✨ Domänen & Tools](#-domänen--tools)
- [🚀 Installation](#-installation)
- [🔧 Env-Variablen](#-env-variablen)
- [🔌 MCP-Clients anbinden](#-mcp-clients-anbinden)
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
        │  🔌 HTTP (OpenAPI, via mcpo)
        ▼
🌍 world-intel-mcp :8030       ← 120 MCP-Tools (stdio) via mcpo
        │
        │  Fetcher → CircuitBreaker → Cache (SQLite) → 🗃 optional Qdrant
        ▼
46+ öffentliche Quellen: Yahoo Finance · SEC EDGAR · FRED · USGS · NASA FIRMS ·
ACLED · GDELT · adsb.lol · OpenSky · Cloudflare Radar · WHO · NOAA · …

📟 Ops-Center-Dashboard :8501   ← SSE-Live-Feeds, Leaflet-Map, Breaker-Health
🔄 Collector (optional)         ← füllt den Qdrant-Store im 5-Min-Intervall
```

| 🧩 Baustein | Beschreibung |
|---|---|
| 🐳 **Dockerfile** | Klont das Upstream-Projekt zur Build-Zeit (per `WORLD_INTEL_REF` pinbar), installiert `.[dashboard,vector]` + `mcpo` |
| 📦 **Portainer-Stack** | `docker-compose.yml` — deploybar direkt aus dem Repository |
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
4. Umgebungsvariablen setzen (siehe [🔧 Env-Variablen](#-env-variablen)) — mindestens `MCP_API_KEY` 🔑
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
  -e MCP_API_KEY=ChangeMe \
  ghcr.io/jbkunama1/hai.worldintelmcp:latest
```

### 🔨 Selbst bauen (Upstream-Version pinnen)

```bash
docker build --build-arg WORLD_INTEL_REF=v0.3.0 -t hai.worldintelmcp .
```

Default ist `main` — mit `WORLD_INTEL_REF` auf jedes Tag des Upstream-Repos pinbar.

---

## 🔧 Env-Variablen

| Variable | Pflicht | Default | Zweck |
|---|---|---|---|
| `MCP_HTTP_PORT` | – | `8030` | 🔌 MCP-Endpoint (HTTP/OpenAPI via mcpo) |
| `DASHBOARD_PORT` | – | `8501` | 📟 Ops-Center-Dashboard (SSE) |
| `MCP_API_KEY` | ⚠️ | *(leer)* | 🔑 API-Key für den MCP-Endpoint (leer = keine Auth) |
| `ENABLE_COLLECTOR` | – | `false` | 🔄 Collector-Daemon: füllt Qdrant im 5-Min-Intervall |
| `QDRANT_URL` | – | *(leer)* | 🗃 z. B. `http://world-intel-qdrant:6333` (Profil `vector`) |
| `TZ` | – | `Europe/Berlin` | 🕐 Zeitzone |

---

## 🔌 MCP-Clients anbinden

mcpo exponiert jeden der 120 Tools als eigenen HTTP-Endpunkt und erzeugt eine OpenAPI-Beschreibung:

- 📘 OpenAPI-Doku: `http://<host>:8030/docs`
- 📄 OpenAPI-JSON: `http://<host>:8030/openapi.json` — hier zeigen AnythingMCP & Co. hin
- 🎯 Ein Tool direkt: `http://<host>:8030/intel_earthquakes?min_magnitude=5.0`

Agenten-Konfiguration (Beispiel):

```json
{
  "mcpServers": {
    "world-intel": {
      "name": "World Intel MCP",
      "type": "streamable",
      "url": "http://world-intel-mcp:8030",
      "enabled": true
    }
  }
}
```

Mit gesetztem `MCP_API_KEY` senden Clients `Authorization: Bearer <KEY>`. 🔐

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
| ❌ Image-Pull schlägt fehl | GHCR-Paket im Repo (Packages) auf Public setzen oder per `docker login ghcr.io` einloggen |
| 📟 Dashboard nicht erreichbar | Port 8501 frei? `DASHBOARD_PORT` prüfen, Container-Logs ansehen |
| 🔌 mcpo liefert 502/Timeout | Erster Start initialisiert Quellen/Caches — kurz warten und erneut versuchen |
| 🐳 Port schon belegt | `MCP_HTTP_PORT`/`DASHBOARD_PORT` ändern und Host-Port in der Compose anpassen |
| 🗃 Qdrant-Verbindung fehlschlägt | Profil `vector` aktiv? `QDRANT_URL` korrekt? Beide Container im `highfishNetwork`? |

---

## 🔐 Sicherheit

- 🔒 Nur in vertrautem Netzwerk oder hinter VPN/HTTPS betreiben — das Dashboard hat keine Auth.
- 🔑 `MCP_API_KEY` setzen, um den MCP-Endpoint zu schützen (Bearer-Token via mcpo).
- ☁️ Extern erreichbar wie gewohnt über Cloudflare Tunnel — Dashboard und MCP-Endpoint getrennt exposen.
- 🐖 TruffleHog-Workflow prüft automatisch auf versehentlich eingecheckte Secrets.

---

## 📄 Lizenz & Credits

- 📄 **MIT** — siehe [LICENSE](LICENSE)
- 🌍 Upstream: [marc-shade/world-intel-mcp](https://github.com/marc-shade/world-intel-mcp) (MIT) — 120 Tools, Dashboard, CLI, Qdrant-Vektor-Store
- 🔌 MCP-zu-HTTP-Bridge: [mcpo](https://github.com/evalstate/mcp-adapter)

---

☕ **hAI.WorldIntelMCP** · Teil des highfishNetwork-Stacks
