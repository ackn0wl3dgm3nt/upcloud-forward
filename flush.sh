#!/usr/bin/env bash
set -euo pipefail

# Pairs of PUBLIC_PORT:INTERNAL_PORT:PROTO to flush
RULES=(
  "8880:1080:tcp"
  "8443:4452:tcp"
  "33434:4433:udp"
)

echo "[*] Flushing REDIRECT rules..."

for entry in "${RULES[@]}"; do
  IFS=':' read -r PUBLIC_PORT INTERNAL_PORT PROTO <<< "$entry"

  echo "[*] Removing PREROUTING ${PROTO} ${PUBLIC_PORT} -> ${INTERNAL_PORT}"
  while iptables -t nat -C PREROUTING -p "${PROTO}" --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}" 2>/dev/null; do
    iptables -t nat -D PREROUTING -p "${PROTO}" --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}"
  done

  echo "[*] Removing OUTPUT ${PROTO} ${PUBLIC_PORT} -> ${INTERNAL_PORT}"
  while iptables -t nat -C OUTPUT -p "${PROTO}" --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}" 2>/dev/null; do
    iptables -t nat -D OUTPUT -p "${PROTO}" --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}"
  done
done

echo "[*] Saving cleared rules persistently..."
netfilter-persistent save

echo "[*] Current NAT table:"
iptables -t nat -L PREROUTING -n --line-numbers
iptables -t nat -L OUTPUT -n --line-numbers

echo "[*] Done."
