FROM quay.io/fedora/fedora-toolbox:44

LABEL com.github.containers.toolbox="true" \
      name="devbox" \
      version="1.0"

# Basic tools
RUN dnf install -y \
    git \
    curl \
    && dnf clean all

# Install Nix
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux --init none --no-confirm

# Source nix in profile
RUN echo 'if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh; fi' >> /etc/profile.d/nix.sh

# Install Devbox
RUN curl -fsSL https://get.jetify.com/devbox | bash -s -- -f
