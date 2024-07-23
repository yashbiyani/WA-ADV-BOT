# Use the official Alpine base image with Python 3.9
FROM python:3.9-alpine AS python-base

# Install necessary packages and create a non-root user
RUN apk update && apk add --no-cache \
    chromium \
    nss \
    font-noto \
    nodejs \
    npm \
    bash \
    && adduser -D user \
    && mkdir -p /home/user/app \
    && chown -R user:user /home/user

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Set working directory and switch to the non-root user
WORKDIR /home/user/app
USER user

# Copy application files and set permissions
COPY --chown=user . /home/user/app

# Ensure the directory for node-persist is writable
RUN mkdir -p /home/user/app/.node-persist && chmod 700 /home/user/app/.node-persist

# Install Node.js dependencies
RUN npm install

# Expose port 7860
EXPOSE 7860

# Command to run the Node.js application
CMD ["node", "index.js"]
