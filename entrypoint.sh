#!/bin/sh
set -e

: "${MCP_HTTP_PORT:=8030}"
: "${MCPO_PORT:=8031}"
: "${DASHBOARD_PORT:=8501}"
: "${ENABLE_COLLECTOR:=false}"
: "${ENABLE_MCPO:=false}"

# Upstream-Dashboard bindet default auf 127.0.0.1 — fuer Docker zwingend 0.0.0.0
export WORLD_INTEL_DASHBOARD_HOST=0.0.0.0
export XDG_CACHE_HOME=/data/cache
mkdir -p /data/cache /data/reports

# Optional: Collector-Daemon füllt den Vektor-Store im Hintergrund (5-Min-Intervall)
if [ "$ENABLE_COLLECTOR" = "true" ]; then
  echo "[entrypoint] starting collector daemon"
  python /opt/world-intel-mcp/collector.py &
fi

# Ops-Center-Dashboard im Hintergrund (Starlette/Uvicorn, --host bewusst gesetzt)
echo "[entrypoint] starting dashboard on 0.0.0.0:${DASHBOARD_PORT}"
intel-dashboard --host 0.0.0.0 --port "$DASHBOARD_PORT" &

# Optional: mcpo als zusaetzlicher OpenAPI-Endpoint (mit optionalem API-Key)
if [ "$ENABLE_MCPO" = "true" ]; then
  if [ -n "$MCP_API_KEY" ]; then
    echo "[entrypoint] starting mcpo (OpenAPI) on :${MCPO_PORT} (api key set)"
    mcpo --api-key "$MCP_API_KEY" --port "$MCPO_PORT" -- world-intel-mcp &
  else
    echo "[entrypoint] starting mcpo (OpenAPI) on :${MCPO_PORT} (no auth)"
    mcpo --port "$MCPO_PORT" -- world-intel-mcp &
  fi
fi

# MCP-Server (stdio) via supergateway als Streamable-HTTP-Endpoint exponieren (foreground)
# Endpoint: http://<host>:${MCP_HTTP_PORT}/mcp  (stateless, mehrere Clients parallel)
echo "[entrypoint] starting supergateway (streamable HTTP /mcp) on :${MCP_HTTP_PORT}"
exec supergateway --stdio "world-intel-mcp" --outputTransport streamableHttp --port "$MCP_HTTP_PORT" --streamableHttpPath /mcp
