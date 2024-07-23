# Use the official Alpine base image with Python 3.9
FROM python:3.9-alpine AS python-base

# Install necessary packages
RUN apk update && apk add --no-cache \
    chromium \
    nss \
    font-noto \
    nodejs \
    npm \
    bash

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Set environment variables and working directory
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH
WORKDIR $HOME/app

# Create a non-root user
RUN adduser -D user

# Create the necessary directory structure and set permissions
RUN mkdir -p $HOME/app && chown -R user:user $HOME

# Switch to the non-root user
USER user

# Copy application files and set user as owner
COPY --chown=user . $HOME/app

# Ensure the directory for node-persist is writable
RUN mkdir -p $HOME/app/.node-persist && chmod 700 $HOME/app/.node-persist

# Install Node.js dependencies
RUN npm install

# Command to run both the Uvicorn server and the Node.js app
CMD ["bash", "-c", "uvicorn app:app --host 0.0.0.0 --port 7860 & node index.js"]
