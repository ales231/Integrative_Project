FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget jq git ca-certificates unzip \
    nmap whatweb lftp ftp \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Dirsearch
RUN git clone --depth 1 https://github.com/maurosoria/dirsearch.git /opt/dirsearch

# Nuclei
ARG NUCLEI_VERSION=3.3.7
RUN curl -fsSL "https://github.com/projectdiscovery/nuclei/releases/download/v${NUCLEI_VERSION}/nuclei_${NUCLEI_VERSION}_linux_amd64.zip" \
    -o /tmp/nuclei.zip \
    && unzip /tmp/nuclei.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/nuclei \
    && rm /tmp/nuclei.zip \
    && nuclei -update-templates || true

# RustScan
ARG RUSTSCAN_VERSION=2.1.1
RUN curl -fsSL "https://github.com/RustScan/RustScan/releases/download/${RUSTSCAN_VERSION}/rustscan_${RUSTSCAN_VERSION}_amd64.deb" \
    -o /tmp/rustscan.deb \
    && dpkg -i /tmp/rustscan.deb || apt-get install -fy \
    && rm /tmp/rustscan.deb

WORKDIR /lab
ENV PATH="/opt/dirsearch:${PATH}"

CMD ["sleep", "infinity"]
