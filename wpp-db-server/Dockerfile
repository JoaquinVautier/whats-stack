# ------------  wpp-db-server · Dockerfile  ------------
FROM node:18-bullseye-slim

# tini para apagado limpio
RUN apt-get update && apt-get install -y tini && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
WORKDIR /usr/src/app

# Instalar dependencias (usa lockfile si existe)
COPY package*.json ./
RUN if [ -f package-lock.json ]; then \
      npm ci --omit=dev ; \
    else \
      npm install --omit=dev ; \
    fi

# Copiar el resto del código
COPY . .

EXPOSE 3001
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "index.js"]
