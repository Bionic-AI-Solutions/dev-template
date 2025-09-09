# Multi-stage Dockerfile for Bionic-AI-Solutions Project
# Supports both Node.js and Python backends with frontend

# =============================================================================
# Base Stage - Common dependencies
# =============================================================================
FROM node:18-alpine AS base
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    postgresql-client \
    curl \
    git \
    && rm -rf /var/cache/apk/*

# =============================================================================
# Development Stage
# =============================================================================
FROM base AS development
WORKDIR /app

# Install development dependencies
RUN apk add --no-cache \
    build-base \
    python3-dev \
    postgresql-dev \
    && rm -rf /var/cache/apk/*

# Copy package files
COPY package*.json ./
COPY requirements*.txt ./

# Install Node.js dependencies
RUN npm install

# Create virtual environment and install Python dependencies
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements-dev.txt

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Change ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose ports
EXPOSE 3000 3001 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Development command
CMD ["npm", "run", "dev"]

# =============================================================================
# Production Build Stage - Node.js
# =============================================================================
FROM base AS nodejs-build
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm install --only=production && npm cache clean --force

# Copy source code
COPY backend/ ./backend/
COPY src/ ./src/

# Build application
RUN npm run build

# =============================================================================
# Production Build Stage - Python
# =============================================================================
FROM base AS python-build
WORKDIR /app

# Copy requirements
COPY requirements.txt ./

# Create virtual environment and install Python dependencies
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY backend/ ./backend/

# =============================================================================
# Production Stage
# =============================================================================
FROM base AS production
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy built application from appropriate build stage
COPY --from=nodejs-build --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=nodejs-build --chown=nodejs:nodejs /app/dist ./dist
COPY --from=nodejs-build --chown=nodejs:nodejs /app/backend ./backend

# Copy Python dependencies if needed
COPY --from=python-build --chown=nodejs:nodejs /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy configuration files
COPY --chown=nodejs:nodejs package*.json ./
COPY --chown=nodejs:nodejs .env.example .env

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Production command
CMD ["npm", "start"]

# =============================================================================
# Frontend Build Stage
# =============================================================================
FROM node:18-alpine AS frontend-build
WORKDIR /app

# Copy frontend package files
COPY frontend/package*.json ./

    # Install dependencies
    RUN npm install

# Copy frontend source
COPY frontend/ ./

# Build frontend
RUN npm run build

# =============================================================================
# Frontend Production Stage
# =============================================================================
FROM nginx:alpine AS frontend-production
WORKDIR /usr/share/nginx/html

# Copy built frontend
COPY --from=frontend-build /app/dist ./

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

