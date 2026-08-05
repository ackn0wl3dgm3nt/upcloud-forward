#!/usr/bin/env bash
set -euo pipefail

PUBLIC_PORT=8880
INTERNAL_PORT=1080

echo "[*] Installing iptables-persistent (needed to survive reboot)..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y iptables-persistent netfilter-persistent

echo "[*] Adding PREROUTING redirect: ${PUBLIC_PORT} -> ${INTERNAL_PORT}"
iptables -t nat -C PREROUTING -p tcp --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}" 2>/dev/null \
  || iptables -t nat -A PREROUTING -p tcp --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}"

echo "[*] Adding OUTPUT redirect (so localhost:${PUBLIC_PORT} also works)"
iptables -t nat -C OUTPUT -p tcp --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}" 2>/dev/null \
  || iptables -t nat -A OUTPUT -p tcp --dport "${PUBLIC_PORT}" -j REDIRECT --to-port "${INTERNAL_PORT}"

echo "[*] Saving rules persistently..."
netfilter-persistent save

echo "[*] Current NAT table:"
iptables -t nat -L PREROUTING -n --line-numbers
iptables -t nat -L OUTPUT -n --line-numbers

echo "[*] Done. Test with:"
echo "    curl -x socks5h://127.0.0.1:${PUBLIC_PORT} https://ifconfig.me"
