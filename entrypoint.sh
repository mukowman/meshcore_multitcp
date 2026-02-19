#!/bin/sh
set -eu

ARGS=""

# Required args (-s and -d)
ARGS="$ARGS -s ${SERVER_ADDR}"
ARGS="$ARGS -d ${DEVICE_ADDR}"

# Optional forwarding listener (-f) and sqlite (-sql)
if [ "${ENABLE_FORWARD}" = "true" ]; then
  ARGS="$ARGS -f ${FORWARD_ADDR}"
fi

if [ "${SQLITE}" = "true" ]; then
  # Put DB in mounted volume; your script uses sqlite_file = 'meshcore_multitcp.db'
  # so we run from /data to keep it persistent.
  cd /data
  ARGS="$ARGS -sql"
else
  cd /app
fi

# Logging controls (-q or -v). Default is info (no flag).
if [ "${LOG_LEVEL}" = "quiet" ]; then
  ARGS="$ARGS -q"
elif [ "${LOG_LEVEL}" = "debug" ]; then
  ARGS="$ARGS -v"
fi

exec python3 /app/meshcore_multitcp.py $ARGS
