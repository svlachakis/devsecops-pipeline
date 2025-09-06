# src/vulnerable-app/Dockerfile
FROM node:18-alpine

# Install Python and build dependencies for bcrypt
RUN apk add --no-cache \
    python3 \
    py3-pip \
    make \
    g++ \
    gcc \
    libc-dev \
    linux-headers

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy app source
COPY . .

# Create non-root user (but app still has vulnerabilities)
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Expose port
EXPOSE 3000

# Start application
CMD ["node", "app.js"]