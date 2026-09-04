#!/bin/sh
set -e

: "${MCP_HTTP_PORT:=8030}"
: "${DASHBOARD_PORT:=8501}"
: "${ENABLE_COLLECTOR:=false}"

export XDG_CACHE_HOME=/data/cache
mkdir -p /data/cache /data/reports

# Optional: Collector-Daemon füllt den Vektor-Store im Hintergrund (5-Min-Intervall)
if [ "$ENABLE_COLLECTOR" = "true" ]; then
  echo "[entrypoint] starting collector daemon"
  python /opt/world-intel-mcp/collector.py &
fi

# Ops-Center-Dashboard im Hintergrund (SSE-Live-Feeds)
echo "[entrypoint] starting dashboard on :${DASHBOARD_PORT}"
intel-dashboard --port "$DASHBOARD_PORT" &

# MCP-Server (stdio) via mcpo als HTTP/OpenAPI-Endpoint exponieren (foreground)
if [ -n "$MCP_API_KEY" ]; then
  echo "[entrypoint] starting mcpo on :${MCP_HTTP_PORT} (api key set)"
  exec mcpo --api-key "$MCP_API_KEY" --port "$MCP_HTTP_PORT" -- world-intel-mcp
else
  echo "[entrypoint] starting mcpo on :${MCP_HTTP_PORT} (no auth)"
  exec mcpo --port "$MCP_HTTP_PORT" -- world-intel-mcp
fi
