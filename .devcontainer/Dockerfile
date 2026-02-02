FROM mcr.microsoft.com/devcontainers/base:jammy AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
#!/usr/bin/env bash
set -eu

apt-get update
apt-get install git curl wget ca-certificates lsof -y --no-install-recommends
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*
EOF

RUN <<EOF
#!/usr/bin/env bash
apt-get update && apt-get install -y \
    build-essential \
    libncurses5-dev \
    libgtk-3-dev \
    libatk1.0-dev \
    libcairo2-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    python3-dev \
    ruby-dev \
    lua5.2 \
    liblua5.2-dev \
    libperl-dev
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*
EOF

RUN <<EOF
#!/usr/bin/env bash
set -eu
git clone https://github.com/vim/vim.git /tmp/vim
cd /tmp/vim
make configure
./configure \
    --with-features=huge \
    --enable-multibyte \
    --enable-python3interp=yes \
    --with-python3-command=python3 \
    --enable-perlinterp=yes \
    --enable-luainterp=yes \
    --enable-rubyinterp=yes \
    --enable-cscope \
    --prefix=/usr/local
make VIMRUNTIMEDIR=/usr/local/share/vim/vim91
make install
rm -rf /tmp/vim
EOF

RUN <<EOF
#!/bin/bash
set -eu
apt-get update
apt-get install -y python3 python3-pip pre-commit
pip3 install uv
pip3 cache purge
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*
EOF

RUN <<EOF
#!/bin/bash
set -eu
curl -fsSL https://apt.cli.rs/pubkey.asc | tee -a /usr/share/keyrings/rust-tools.asc
curl -fsSL https://apt.cli.rs/rust-tools.list | tee /etc/apt/sources.list.d/rust-tools.list
apt update
apt install -y ripgrep zoxide
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*
EOF

RUN sed -i '/^[^:]*:[^:]*:1000:/ s|:/bin/bash$|:/usr/bin/zsh|' /etc/passwd

ENV DEBIAN_FRONTEND=dialog