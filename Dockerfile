FROM node:18-bullseye-slim

# Chrome 135 dependencias + tini
RUN apt-get update && \
    apt-get install -y wget gnupg ca-certificates fonts-liberation \
                       libatk1.0-0 libatk-bridge2.0-0 libc6 libpangocairo-1.0-0 \
                       libx11-xcb1 libxcb1 libdrm2 libgbm1 libgtk-3-0 libxcomposite1 \
                       libxdamage1 libxrandr2 libxshmfence1 libxkbcommon0 libxrender1 \
                       libnss3 libpango-1.0-0 libpangocairo-1.0-0 libatspi2.0-0 && \
    wget -O /tmp/chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_135.0.7049.84-1_amd64.deb && \
    apt-get install -y /tmp/chrome.deb && \
    rm /tmp/chrome.deb && rm -rf /var/lib/apt/lists/* && \
    apt-get install -y tini && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production \
    PUPPETEER_SKIP_DOWNLOAD=true \
    GOOGLE_CHROME_BIN=/usr/bin/google-chrome

WORKDIR /usr/src/app

COPY package*.json ./
# <-- aquí el cambio clave -->
RUN npm install --omit=dev --legacy-peer-deps

COPY . .
RUN npm run build

EXPOSE 21465
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "dist/server.js"]
