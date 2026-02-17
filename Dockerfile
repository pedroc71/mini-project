# ===== BUILD STAGE =====
FROM node:20 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
 

COPY app.js .

# ===== RUNTIME STAGE =====
FROM node:20-alpine
WORKDIR /app

# Create non-root user
RUN NPM_DIR=/usr/local/lib/node_modules/npm && \
    sed -i 's/"cross-spawn": "[^"]*"/"cross-spawn": "7.0.6"/' $NPM_DIR/package.json && \
    cd $NPM_DIR/node_modules/cross-spawn && \
    sed -i 's/"version": "7.0.3"/"version": "7.0.6"/' package.json && \
    sed -i 's/"version": "10.4.2"/"version": "10.5.0"/' $NPM_DIR/node_modules/glob/package.json && \
    sed -i 's/"version": "6.2.1"/"version": "7.5.7"/' $NPM_DIR/node_modules/tar/package.json 

COPY --from=builder /app /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup


USER appuser

EXPOSE 3000
CMD ["node", "app.js"]
