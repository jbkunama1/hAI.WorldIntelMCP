# hAI.WorldIntelMCP — World-Intel-MCP (marc-shade) als Docker-Container
# Upstream: https://github.com/marc-shade/world-intel-mcp (MIT)
FROM python:3.12-slim

# Upstream-Ref pinbar: --build-arg WORLD_INTEL_REF=v0.3.0
ARG WORLD_INTEL_REF=main

RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone --depth 1 --branch "${WORLD_INTEL_REF}" https://github.com/marc-shade/world-intel-mcp.git

WORKDIR /opt/world-intel-mcp

# Kern + Dashboard (SSE Ops-Center) + Vektor-Store (Qdrant/FastEmbed)
# mcpo: exponiert den stdio-MCP-Server als HTTP/OpenAPI-Endpoint
RUN pip install --no-cache-dir -e ".[dashboard,vector]" \
 && pip install --no-cache-dir mcpo

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && mkdir -p /data/cache /data/reports

EXPOSE 8030 8501

# Standard-Umgebungsvariablen (über Portainer/Compose überschreibbar)
ENV MCP_HTTP_PORT=8030 \
    DASHBOARD_PORT=8501 \
    MCP_API_KEY="" \
    ENABLE_COLLECTOR=false \
    QDRANT_URL="" \
    XDG_CACHE_HOME=/data/cache \
    STREAMLIT_SERVER_ADDRESS=0.0.0.0 \
    STREAMLIT_SERVER_HEADLESS=true

ENTRYPOINT ["/entrypoint.sh"]
