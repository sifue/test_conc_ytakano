# ---- 0. マルチアーキ対応 ----------
ARG UBUNTU_VERSION=24.04
FROM --platform=$TARGETPLATFORM ubuntu:${UBUNTU_VERSION}

# ---- 1. 基本ツール ----------
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    # C/C++ (32bit/64bit 混在)
    build-essential gcc-multilib libc6-dev-i386 \
    # アセンブリ
    nasm gdb lldb \
    # 便利系
    git curl ca-certificates neovim \
 && rm -rf /var/lib/apt/lists/*

# ---- 2. Rust ----------
ARG RUST_VERSION=1.87.0
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain ${RUST_VERSION} \
           --profile minimal --no-modify-path \
 && rustup component add rustfmt clippy

# ---- 3. デフォルトシェル ----------
CMD [ "bash" ]
