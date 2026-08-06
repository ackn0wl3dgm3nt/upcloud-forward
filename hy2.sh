#!/usr/bin/env bash
set -euo pipefail
PUBLIC_PORT=33434
INTERNAL_PORT=4433

echo "[*] Installing iptables-persistent (needed to survive reboot)..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y iptables-persistent netfilter-persistent

echo "[*] Adding PREROUTING redirect (UDP): ${PUBLIC_PORT} -> ${INTERNAL_PORT}"
iptables -t nat -C PREROUTING -p udp --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}" 2>/dev/null \
  || iptables -t nat -A PREROUTING -p udp --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}"

echo "[*] Adding OUTPUT redirect (UDP, so localhost:${PUBLIC_PORT} also works)"
iptables -t nat -C OUTPUT -p udp --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}" 2>/dev/null \
  || iptables -t nat -A OUTPUT -p udp --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}"

echo "[*] Saving rules persistently..."
netfilter-persistent save

echo "[*] Current NAT table:"
iptables -t nat -L PREROUTING -n --line-numbers
iptables -t nat -L OUTPUT -n --line-numbers

echo "[*] Done. Test with a Hysteria2 client pointed at udp/${PUBLIC_PORT} (server actually listening on ${INTERNAL_PORT})."
