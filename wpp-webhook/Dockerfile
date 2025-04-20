# ------------  wpp-webhook · Dockerfile  ------------
FROM node:18-bullseye-slim

RUN apt-get update && apt-get install -y tini && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
WORKDIR /usr/src/app

COPY package*.json ./
RUN if [ -f package-lock.json ]; then \
      npm ci --omit=dev ; \
    else \
      npm install --omit=dev ; \
    fi

COPY . .

EXPOSE 3005
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
