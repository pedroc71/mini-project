# ======================
# BUILD STAGE
# ======================
FROM node:20 AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with updated versions
RUN npm ci --omit=dev && npm cache clean --force

# Copy application code
COPY . .

# ======================
# PRODUCTION STAGE
# ======================
FROM node:20-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -S app && adduser -S app -G app

# Copy from builder
COPY --from=builder /app /app

# Fix ownership
RUN chown -R app:app /app

# Create volume
VOLUME ["/app/data"]

# Switch to non-root user
USER app

# Expose port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Start app
CMD ["node", "index.js"]