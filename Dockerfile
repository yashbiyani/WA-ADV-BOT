FROM python:3.9-slim

# Set working directory
WORKDIR /code

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    chromium \
    libnss3 \
    fonts-freefont-ttf \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install the latest npm
RUN npm install -g npm@latest

# Create a non-root user
RUN useradd -m -u 1000 user
USER user

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Set environment variables and working directory
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH
WORKDIR $HOME/app

# Copy application files and set user as owner
COPY --chown=user . $HOME/app

# Install Node.js dependencies
RUN npm install

# Command to run both the Uvicorn server and the Node.js app
CMD ["bash", "-c", "uvicorn app:app --host 0.0.0.0 --port 7860 & node index.js"]
