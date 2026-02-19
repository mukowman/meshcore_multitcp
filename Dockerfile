FROM python:3.12-slim

# Prevents python from writing .pyc files and buffers
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps (kept minimal). sqlite3 CLI is optional, but handy for debugging DB files.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Install python deps
# meshcore is required per README
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir meshcore

# Copy app
COPY meshcore_multitcp.py meshcore_multitcp_packets.py ./ 
COPY entrypoint.sh /entrypoint.sh

# Create a non-root user
RUN useradd -r -u 10001 -g users appuser \
    && chown -R appuser:users /app \
    && chmod +x /entrypoint.sh

USER appuser

# Default ports from your script
EXPOSE 5000 5001

# SQLite DB lives in /data so it can be mounted as a volume
VOLUME ["/data"]

# Default envs (override at runtime)
ENV SERVER_ADDR="0.0.0.0:5000" \
    FORWARD_ADDR="0.0.0.0:5001" \
    DEVICE_ADDR="192.168.5.62:5000" \
    LOG_LEVEL="info" \
    SQLITE="false" \
    ENABLE_FORWARD="false"

ENTRYPOINT ["/entrypoint.sh"]
