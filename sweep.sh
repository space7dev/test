#!/bin/bash
exec 2>&1
echo "=== host ==="; hostname; uptime; date -u
echo "=== docker ps ==="; docker ps --format '{{.Names}} | {{.Image}} | {{.Ports}} | {{.Status}}'
echo "=== networks ==="; docker network ls; for n in $(docker network ls -q); do echo "-- $n"; docker network inspect $n --format '{{.Name}} {{range .Containers}} {{.Name}}={{.IPv4Address}}{{end}}'; done
echo "=== listening ==="; ss -lntup
echo "=== grep key-service in tree ==="
grep -rIln -iE "key.?service|keyservice|KEY_SVC|KEY_SERVICE_URL|wallet.?key|ENCRYPTION_KEY" /opt /root /etc/caddy /srv /usr/local/etc 2>/dev/null | grep -v node_modules | head -50
echo "=== compose/env matches ==="
grep -rIn -iE "key.?serv|KEY_SVC|ENCRYPTION|MNEMONIC|PASSCODE|wallet" /opt/studio-standby/docker-compose.yml /opt/studio-standby/*.env /opt/studio-standby/env* 2>/dev/null | head -80
echo "=== ls compose dir ==="; ls -la /opt/studio-standby | head -60
echo "=== all env files ==="; find /opt /root /srv /etc -maxdepth 4 \( -name '*.env' -o -name '.env*' -o -name '*.env.*' \) 2>/dev/null | grep -v node_modules | head -60
echo "=== grep API tokens/urls in env files ==="
for f in $(find /opt/studio-standby -maxdepth 2 -name '*.env' -o -maxdepth 2 -name '.env' 2>/dev/null); do echo "## $f"; grep -iE "key|serv|port|url|token|secret" $f; done
echo "=== hostnames in caddyfile ==="; grep -nE "reverse_proxy|:[0-9]{4,5}" /opt/studio-standby/Caddyfile | head -40
echo "=== ss established to internal ==="; ss -tnp | head -40
echo "=== quick port scan on localhost ==="; for p in 3000 4000 5000 6000 7000 8000 8080 8081 9000 9090 3001 4001 5001 5732 27017 6379; do timeout 1 bash -c "echo >/dev/tcp/127.0.0.1/$p" 2>/dev/null && echo "OPEN $p"; done
echo "=== DONE ==="
