# -------------------------------------------
#  wpp-db-server  ·  Dockerfile
#  Base: Node 18.x (bullseye-slim)
# -------------------------------------------
FROM node:18-bullseye-slim

# Instala tini para controlar señales (graceful shutdown)
RUN apt-get update && apt-get install -y tini && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
WORKDIR /usr/src/app

# Copiamos sólo package.json y lock para cache de capas
COPY package*.json ./

# Instala dependencias de producción
RUN \
  if [ -f package-lock.json ]; then npm ci --omit=dev ; \
  else npm install --omit=dev ; fi

# Copia el resto del código fuente
COPY . .

# Puerto expuesto (ajusta si cambiaste)
EXPOSE 3001

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "index.js"]

