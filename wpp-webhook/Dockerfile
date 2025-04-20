# -------------------------------------------
#  wpp-webhook · Dockerfile
#  Base: Node 18.x (bullseye‑slim) — igual que el backend
# -------------------------------------------
FROM node:18-bullseye-slim

# Tini para manejar señales correctamente
RUN apt-get update && apt-get install -y tini && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
WORKDIR /usr/src/app

# Instala deps usando el lock si existe
COPY package*.json ./
RUN \
  if [ -f package-lock.json ]; then npm ci --omit=dev ; \
  else npm install --omit=dev ; fi

# Copiamos el resto del código
COPY . .

# Cambia si tu webhook escucha otro puerto
EXPOSE 3005

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "webhook.js"]

