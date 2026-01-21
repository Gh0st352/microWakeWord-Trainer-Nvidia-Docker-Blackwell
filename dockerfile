# Base
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 python3.12-venv python3.12-dev python3-pip python-is-python3 \
    git wget curl unzip ca-certificates nano less \
    gnupg2 lsb-release \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /data

# CUDA 13.0 toolkit (Blackwell-compatible) from NVIDIA repo
RUN curl -fsSL \
      https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb \
      -o /tmp/cuda-keyring.deb \
 && dpkg -i /tmp/cuda-keyring.deb \
 && rm -f /tmp/cuda-keyring.deb \
 && apt-get update \
 && apt-get install -y --no-install-recommends cuda-toolkit-13-0 \
 && rm -rf /var/lib/apt/lists/*

ENV CUDA_HOME=/usr/local/cuda
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64

# Recorder port
EXPOSE 8789

# Script root
WORKDIR /root/mww-scripts

# Bash environment
COPY --chown=root:root --chmod=0755 .bashrc /root/

# Root-level entrypoints
COPY --chown=root:root --chmod=0755 \
    train_wake_word \
    run_recorder.sh \
    recorder_server.py \
    requirements.txt \
    /root/mww-scripts/

# CLI folder
COPY --chown=root:root cli/ /root/mww-scripts/cli/

# Make all CLI scripts executable (avoids "Permission denied")
RUN chmod -R a+x /root/mww-scripts/cli

# Static UI for recorder
COPY --chown=root:root --chmod=0644 static/index.html /root/mww-scripts/static/index.html

# recorder server
CMD ["/bin/bash", "-lc", "/root/mww-scripts/run_recorder.sh"]
