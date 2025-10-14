# syntax=docker/dockerfile:1.7

ARG APP_DIR=backend

###############
# Build stage #
###############
FROM node:22-alpine AS builder

WORKDIR /app

# Install system dependencies (CA certs for outbound TLS, etc.)
RUN apk add --no-cache ca-certificates openssl

# Copy manifest files from the backend directory
ARG APP_DIR
COPY ${APP_DIR}/package*.json ./

# Install dependencies (prefer npm ci when lockfile exists)
RUN if [ -f package-lock.json ]; then npm ci --ignore-scripts; else npm install --ignore-scripts; fi \
    && npm cache clean --force

# Copy application source
COPY ${APP_DIR}/. .

# Generate Prisma client & build NestJS
RUN npx prisma generate \
 && npm run build

###################
# Production stage#
###################
FROM node:22-alpine AS production

WORKDIR /app

# Install runtime system dependencies (TLS certs, etc.)
RUN apk add --no-cache ca-certificates openssl

ARG APP_DIR
ENV NODE_ENV=production

# Copy manifest files and install production dependencies
COPY ${APP_DIR}/package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev --ignore-scripts; else npm install --omit=dev --ignore-scripts; fi \
    && npm cache clean --force

# Copy compiled artifacts and prisma assets from build stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /app/prisma ./prisma

# Create unprivileged user
RUN addgroup -g 1001 -S nodejs \
 && adduser -S nestjs -u 1001 \
 && chown -R nestjs:nodejs /app

USER nestjs

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:'+(process.env.PORT||8000)+'/api/v1', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "dist/src/main"]
