# upcloud-forward

Port forwarding scripts for UpCloud nodes (TCP/UDP REDIRECT via iptables).

**XHTTP forward (8443 → 4452):**
```
curl -fsSL https://raw.githubusercontent.com/ackn0wl3dgm3nt/upcloud-forward/main/xhttp.sh | bash
```

**SOCKS5 forward (8880 → 1080):**
```
curl -fsSL https://raw.githubusercontent.com/ackn0wl3dgm3nt/upcloud-forward/main/socks5.sh | bash
```

**Hysteria2 forward (33434 → 4433):**
```
curl -fsSL https://raw.githubusercontent.com/ackn0wl3dgm3nt/upcloud-forward/main/hy2.sh | bash
```

**Flush all rules:**
```
curl -fsSL https://raw.githubusercontent.com/ackn0wl3dgm3nt/upcloud-forward/main/flush.sh | bash
```
