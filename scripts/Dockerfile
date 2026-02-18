FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    pandoc \
    texlive-latex-base \
    texlive \
    texlive-latex-extra \
    texlive-fonts-extra \
    fonts-roboto \
    texlive-latex-recommended \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Brave Browser with necessary dependencies for headless mode
RUN curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list \
    && apt-get update \
    && apt-get install -y brave-browser \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables to disable DBUS and unnecessary services
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null \
    DISABLE_DBUS=1

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
