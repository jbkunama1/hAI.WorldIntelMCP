# hAI.WorldIntelMCP

World-Intel-MCP ([marc-shade/world-intel-mcp](https://github.com/marc-shade/world-intel-mcp)) als Portainer-Stack: **120 MCP-Tools** für Echtzeit-Global-Intelligence über **30+ Domänen** – Märkte, Konflikte, Militär, Cyber, Klima, News und mehr. Alle Datenquellen sind kostenlose, öffentliche APIs. Der stdio-MCP-Server wird via **mcpo** als HTTP-Endpoint exponiert, das Ops-Center-Dashboard läuft direkt mit im Container.

[![Build and publish Docker image](https://github.com/jbkunama1/hAI.WorldIntelMCP/actions/workflows/docker-image.yml/badge.svg)](https://github.com/jbkunama1/hAI.WorldIntelMCP/actions/workflows/docker-image.yml)
[![TruffleHog](https://github.com/jbkunama1/hAI.WorldIntelMCP/actions/workflows/trufflehog.yml/badge.svg)](https://github.com/jbkunama1/hAI.WorldIntelMCP/actions/workflows/trufflehog.yml)
[![Docker Image](https://img.shields.io/badge/ghcr.io-image-2496ED?logo=docker&logoColor=white)](https://github.com/jbkunama1/hAI.WorldIntelMCP/pkgs/container/hai.worldintelmcp)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

```
MCP client / AnythingMCP / Agenten
        |
        |  HTTP (OpenAPI, via mcpo)
        v
world-intel-mcp :8030           <-- 120 MCP-Tools (stdio) via mcpo
        |
        |  Fetcher -> CircuitBreaker -> Cache (SQLite) -> optional Qdrant
        v
46+ öffentliche Quellen: Yahoo Finance, SEC EDGAR, USGS, NASA FIRMS,
ACLED, GDELT, adsb.lol, Cloudflare Radar, FRED, WHO, NOAA, ...

    Ops-Center-Dashboard :8501   <-- SSE-Live-Feeds, Leaflet-Map, Circuit-Breaker-Health
    Collector (optional)         <-- füllt den Qdrant-Vektor-Store im Hintergrund
```

## Inhalte

- **Dockerfile** – klont das Upstream-Projekt zur Build-Zeit (per `WORLD_INTEL_REF` pinbar), installiert `.[dashboard,vector]` + `mcpo`
- **Portainer-Stack** – `docker-compose.yml`, deploybar direkt aus dem Repository
- **GHCR-Image** – GitHub Actions pusht nach `ghcr.io/jbkunama1/hai.worldintelmcp:latest`
- **TruffleHog-Workflow** – Secret-Scan bei jedem Push/PR
- **Optionaler Qdrant-Service** – semantische Suche über angesammelte Intelligence (Profil `vector`)

---

## Domänen-Überblick (Auswahl)

| Domäne | Tools | Quellen (Beispiele) |
|---|---|---|
| Finanzmärkte & Forex | 12 | Yahoo Finance, CoinGecko, ECB/Frankfurter |
| Bonds, Earnings & SEC | 7 | FRED, SEC EDGAR (Full-Text, 8-K) |
| Makro & Notenbanken | 8 | FRED, World Bank, 15 Zentralbanken |
| Konflikte & Sicherheit | 4 | ACLED, UCDP, Unrest-Detection |
| Militär & Verteidigung | 6 | adsb.lol, OpenSky, hexdb.io, Surge-Detection |
| Naturkatastrophen & Klima | 7 | USGS, NASA FIRMS/EONET, GDACS, Open-Meteo |
| Infrastruktur & Maritime | 6 | Cloudflare Radar, Seekabel, NGA, FAA |
| News & Medien | 3 | 119 RSS-Feeds (4-Tier), GDELT, Trends |
| Analyse & Synthese | 12+ | Signal-Konvergenz, Instabilitätsindex, Eskalation |
| Geospatial | 11 | Basen, Häfen, Pipelines, Kernkraft, Rechenzentren |
| Cyber & Health | 2 | URLhaus, CISA KEV, WHO DON, ProMED |
| KI & Technologie | 4 | arXiv, HuggingFace, Hacker News, GitHub Trending |
| Vektor-Suche (Qdrant) | 5 | semantische Suche, Timeline, Stats |
| AOI-Geofences & Briefings | 7+ | eigene Zonen, zitierte Briefings, Daily Digest |

Gesamt: **120 Tools** über 30+ Domänen – Details im [Upstream-README](https://github.com/marc-shade/world-intel-mcp).

---

## Deployment via Portainer (Stack)

1. **Stacks → Add stack → Repository**
2. Repository-URL: `https://github.com/jbkunama1/hAI.WorldIntelMCP.git`
3. Compose-Pfad: `docker-compose.yml`, Branch: `main`
4. Umgebungsvariablen setzen (`.env`-Vorlage):

| Variable | Default | Zweck |
|---|---|---|
| `MCP_HTTP_PORT` | `8030` | MCP-Endpoint (HTTP/OpenAPI via mcpo) |
| `DASHBOARD_PORT` | `8501` | Ops-Center-Dashboard (SSE) |
| `MCP_API_KEY` | *(leer)* | **API-Key für den MCP-Endpoint** (leer = keine Auth) |
| `ENABLE_COLLECTOR` | `false` | Collector-Daemon: füllt Qdrant im 5-Min-Intervall |
| `QDRANT_URL` | *(leer)* | z. B. `http://world-intel-qdrant:6333` (Profil `vector`) |
| `TZ` | `Europe/Berlin` | Zeitzone |

5. Docker-Netzwerk (falls nicht vorhanden): `docker network create highfishNetwork`.

Die Compose-Datei referenziert bereits:

```text
image: ghcr.io/jbkunama1/hai.worldintelmcp:latest
```

Cache (SQLite), Vektor-Store-Daten und Reports liegen im Volume-Mount `./data`, nicht im Image.

### Qdrant aktivieren (semantische Suche)

In Portainer die Environment-Variable `QDRANT_URL=http://world-intel-qdrant:6333` setzen und den Stack mit dem Profil `vector` deployen (Portainer: Stack → Redeploy → Optionen → Compose-Profile `vector`). Alternativ lokal:

```bash
docker compose --profile vector up -d
```

---

## Kurzstart (lokal)

```bash
docker build -t hai.worldintelmcp .
docker run -d --name world-intel-mcp \
  -p 8030:8030 -p 8501:8501 \
  -v ./data:/data \
  hai.worldintelmcp
```

- MCP/OpenAPI: `http://localhost:8030` (OpenAPI-Doku: `/docs`)
- Dashboard: `http://localhost:8501`

Upstream-Version pinnen (Default: `main`):

```bash
docker build --build-arg WORLD_INTEL_REF=v0.3.0 -t hai.worldintelmcp .
```

MCP-Client/AnythingMCP-Konfiguration (mcpo-Endpoint, OpenAPI-kompatibel):

```json
{
  "mcpServers": {
    "world-intel": {
      "name": "World Intel MCP",
      "type": "streamable",
      "url": "http://world-intel-mcp:8030/docs",
      "enabled": true
    }
  }
}
```

Agenten, die OpenAPI statt MCP sprechen, erreichen jedes Tool direkt unter `http://host:8030/<toolname>` – die OpenAPI-Beschreibung liegt unter `http://host:8030/openapi.json`.

---

## CLI im Container

```bash
docker exec -it world-intel-mcp intel markets
#Alle Tools: docker exec -it world-intel-mcp intel status
docker exec -it world-intel-mcp intel earthquakes --min-mag 5.0
docker exec -it world-intel-mcp intel status
```

Der Collector-Daemon (`ENABLE_COLLECTOR=true`) fetched alle 46 Quellen parallel und befüllt den Vektor-Store – Basis für semantische Anfragen wie „Militäraktivität nahe Taiwan“.

---

## Sicherheit

- Nur in vertrautem Netzwerk oder hinter VPN/HTTPS betreiben – das Dashboard hat keine Auth.
- `MCP_API_KEY` setzen, um den MCP-Endpoint zu schützen (mcpo prüft den Key als Bearer-Token).
- Extern erreichbar machen wie gewohnt über Cloudflare Tunnel – Dashboard und MCP-Endpoint getrennt exposen.
- Alle Datenquellen sind öffentlich und kostenlos; es fließen keine API-Keys nach außen.
- TruffleHog-Workflow prüft automatisch auf versehentlich eingecheckte Secrets.

## Credits

- Upstream: [marc-shade/world-intel-mcp](https://github.com/marc-shade/world-intel-mcp) (MIT) – 120 Tools, Dashboard, CLI, Qdrant-Vektor-Store
- MCP-zu-HTTP-Bridge: [mcpo](https://github.com/evalstate/mcp-adapter)

## Lizenz

MIT
