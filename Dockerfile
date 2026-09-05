# hAI.WorldIntelMCP — World-Intel-MCP (marc-shade) als Docker-Container
# Upstream: https://github.com/marc-shade/world-intel-mcp (MIT)
FROM python:3.12-slim

# Upstream-Ref pinbar: --build-arg WORLD_INTEL_REF=v0.3.0
ARG WORLD_INTEL_REF=main

# git: Upstream klonen · Node 22: supergateway (stdio -> Streamable HTTP)
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates curl \
 && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone --depth 1 --branch "${WORLD_INTEL_REF}" https://github.com/marc-shade/world-intel-mcp.git

WORKDIR /opt/world-intel-mcp

# Kern + Dashboard (SSE Ops-Center) + Vektor-Store (Qdrant/FastEmbed)
# supergateway: exponiert den stdio-MCP-Server als Streamable HTTP (/mcp)
# mcpo: optionaler OpenAPI-Endpoint (ENABLE_MCPO=true)
RUN pip install --no-cache-dir -e ".[dashboard,vector]" \
 && pip install --no-cache-dir mcpo \
 && npm install -g supergateway

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && mkdir -p /data/cache /data/reports

EXPOSE 8030 8031 8501

# Standard-Umgebungsvariablen (über Portainer/Compose überschreibbar)
# WICHTIG: Das Upstream-Dashboard (Starlette/Uvicorn) bindet default auf 127.0.0.1 —
# ohne WORLD_INTEL_DASHBOARD_HOST=0.0.0.0 ist es außerhalb des Containers unerreichbar!
ENV MCP_HTTP_PORT=8030 \
    MCPO_PORT=8031 \
    DASHBOARD_PORT=8501 \
    WORLD_INTEL_DASHBOARD_HOST=0.0.0.0 \
    MCP_API_KEY="" \
    ENABLE_COLLECTOR=false \
    ENABLE_MCPO=false \
    QDRANT_URL="" \
    XDG_CACHE_HOME=/data/cache

ENTRYPOINT ["/entrypoint.sh"]
