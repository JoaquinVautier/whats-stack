# ------------  wpp-db-server · Dockerfile  ------------
FROM node:18-bullseye-slim

# ------------------------------------------------------
# 1) tini → apagado limpio
# ------------------------------------------------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends tini \
 && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
WORKDIR /usr/src/app

# ------------------------------------------------------
# 2) Dependencias  (usa lockfile si existe)
# ------------------------------------------------------
COPY package*.json ./
RUN if [ -f package-lock.json ]; then \
      npm ci --omit=dev ; \
    else \
      npm install --omit=dev ; \
    fi

# ------------------------------------------------------
# 3) Copiar código + nuevo entrypoint
# ------------------------------------------------------
COPY . .
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# ------------------------------------------------------
# 4) Puertos & arranque
# ------------------------------------------------------
EXPOSE 3001

# tini (PID 1) ➜ entrypoint.sh ➜ node index.js
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/src/app/entrypoint.sh"]
