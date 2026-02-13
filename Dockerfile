# ===== BUILD STAGE =====
FROM node:20 AS builder

WORKDIR /app
COPY package*.json .
RUN npm ci --production
COPY app.js .

# ===== RUNTIME STAGE =====
FROM node:20-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

#  CRITICAL FIX: Remove npm completely - not needed at runtime
RUN npm cache clean --force && \
    rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm

COPY --from=builder /app /app

# Fix permissions
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000
CMD ["node", "app.js"]
