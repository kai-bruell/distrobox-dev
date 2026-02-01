FROM docker.io/library/alpine:latest

LABEL com.github.containers.toolbox="true" \
      name="devbox" \
      version="1.0"

# Install tools required by distrobox
RUN apk add --no-cache \
    bash coreutils curl git sudo shadow \
    grep sed gawk findutils procps-ng util-linux \
    ncurses less openssh-client wget xz \
    mandoc man-pages musl-locales

# Create /etc/os-release entries distrobox expects
RUN echo 'ID=alpine' >> /etc/os-release

# Download nix-portable from correct repo (DavHau)
RUN curl -L https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m) -o /usr/local/bin/nix-portable && \
    chmod +x /usr/local/bin/nix-portable

# Create wrapper for nix command
RUN printf '#!/bin/sh\nexec /usr/local/bin/nix-portable nix "$@"\n' > /usr/local/bin/nix && \
    chmod +x /usr/local/bin/nix

# Install Devbox
RUN curl -fsSL https://get.jetify.com/devbox | bash -s -- -f && \
    chmod +r /usr/local/bin/devbox

# Create /nix directory and setup script for symlinks
# Symlinks are created on first login since ~/.nix-portable doesn't exist at build time
RUN mkdir -p /nix && \
    printf '#!/bin/sh\nif [ ! -L /nix/store ] && [ -d "$HOME/.nix-portable/nix/store" ]; then\n  sudo ln -sf "$HOME/.nix-portable/nix/store" /nix/store 2>/dev/null\n  sudo ln -sf "$HOME/.nix-portable/nix/var" /nix/var 2>/dev/null\nfi\n' > /etc/profile.d/nix-portable-setup.sh && \
    chmod +x /etc/profile.d/nix-portable-setup.sh
