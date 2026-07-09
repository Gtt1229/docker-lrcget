FROM docker.io/jlesage/baseimage-gui:ubuntu-24.04-v4.10.7

# Set LRCGET version
ARG LRCGET_VERSION=2.1.0

# Set environment variables
ENV APP_NAME="LRCGET" \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=768 \
    KEEP_APP_RUNNING=1

# Install dependencies and download prebuilt LRCGET
RUN set -x && \
    # Update package lists
    apt-get update && \
    # Install dependencies
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        # AppImage dependencies
        fuse3 \
        libfuse3-3 \
        # GTK and WebKit dependencies
        libwebkit2gtk-4.1-0 \
        libgtk-3-0 \
        libayatana-appindicator3-1 \
        # Audio support dependencies
        libgstreamer1.0-0 \
        libgstreamer-plugins-base1.0-0 \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
        gstreamer1.0-alsa \
        pulseaudio \
        libpulse0 \
        # Additional UI dependencies
        dbus-x11 \
        openbox \
        && \
    # Download LRCGET AppImage
    echo "Downloading LRCGET v${LRCGET_VERSION}..." && \
    wget -q --show-progress \
        "https://github.com/tranxuanthang/lrcget/releases/download/${LRCGET_VERSION}/LRCGET_${LRCGET_VERSION}_amd64.AppImage" \
        -O /usr/local/bin/lrcget.AppImage && \
    chmod +x /usr/local/bin/lrcget.AppImage && \
    # Extract AppImage (AppImages don't work well in Docker without --appimage-extract-and-run)
    cd /usr/local/bin && \
    ./lrcget.AppImage --appimage-extract && \
    mv squashfs-root /opt/lrcget && \
    rm lrcget.AppImage && \
    # Create wrapper script
    echo '#!/bin/bash\nexec /opt/lrcget/AppRun "$@"' > /usr/local/bin/lrcget && \
    chmod +x /usr/local/bin/lrcget && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the startup script
COPY docker/startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

# Set up volumes for configuration and music library
VOLUME ["/config", "/music"]

# Expose ports
# 5800: Web interface (HTTP)
# 5900: VNC
EXPOSE 5800 5900
