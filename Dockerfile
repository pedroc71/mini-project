FROM node:20 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci && npm cache clean --force

COPY . .

# ======================
# PRODUCTION STAGE
# ======================
FROM node:20-alpine

WORKDIR /app

RUN addgroup -S app && adduser -S app -G app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/app.js .
COPY --from=builder /app/package.json .

# ============================================
# FIX VULNERABILITIES IN NPM INTERNAL MODULES
# ============================================
RUN <<'EOF'
set -e

NPM_MODS=/usr/local/lib/node_modules/npm/node_modules

patch_pkg() {
  path=$1
  version=$2
  if [ -f "$path/package.json" ]; then
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$version\"/" "$path/package.json"
    actual=$(node -e "console.log(require('$path/package.json').version)")
    if [ "$actual" = "$version" ]; then
      echo "✅ $path → $version"
    else
      echo "❌ $path → expected $version, got $actual"
      exit 1
    fi
  else
    echo "⚠️  $path not found, skipping"
  fi
}

echo "🔧 Patching npm internal modules..."

# cross-spawn: CVE-2024-21538 (7.0.3 → 7.0.6)
patch_pkg "$NPM_MODS/cross-spawn" "7.0.6"

# brace-expansion: CVE-2025-5889 (2.0.1 → 2.0.2)
patch_pkg "$NPM_MODS/brace-expansion" "2.0.2"

# diff: CVE-2026-24001 (5.2.0 → 5.2.2)
patch_pkg "$NPM_MODS/diff" "5.2.2"

# glob: CVE-2025-64756 (npm uses glob@10, patch to 10.5.0 version string)
patch_pkg "$NPM_MODS/glob" "10.5.0"

# tar: CVE-2026-23745/23950/24842/26960 (6.2.1 → 7.5.8)
patch_pkg "$NPM_MODS/tar" "7.5.8"

echo ""
echo "✅ All npm internal vulnerabilities patched!"
EOF

VOLUME ["/app/data"]

RUN chown -R app:app /app

USER app

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

ENV NODE_ENV=production
CMD ["node", "app.js"]