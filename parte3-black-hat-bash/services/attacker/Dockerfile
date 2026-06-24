FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget jq git ca-certificates unzip \
    nmap whatweb lftp ftp \
    python3 python3-pip python3-requests \
    && rm -rf /var/lib/apt/lists/*

# Dirsearch
RUN git clone --depth 1 https://github.com/maurosoria/dirsearch.git /opt/dirsearch \
    && pip3 install --break-system-packages -r /opt/dirsearch/requirements.txt 2>/dev/null || \
       pip3 install --break-system-packages requests

# Nuclei
ARG NUCLEI_VERSION=3.3.7
RUN curl -fsSL "https://github.com/projectdiscovery/nuclei/releases/download/v${NUCLEI_VERSION}/nuclei_${NUCLEI_VERSION}_linux_amd64.zip" \
    -o /tmp/nuclei.zip \
    && unzip /tmp/nuclei.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/nuclei \
    && rm /tmp/nuclei.zip \
    && nuclei -update-templates || true

# RustScan 2.4.1 — .deb via bee-san/RustScan
RUN curl -fsSL "https://github.com/bee-san/RustScan/releases/download/2.4.1/rustscan.deb.zip" \
    -o /tmp/rustscan.deb.zip \
    && unzip /tmp/rustscan.deb.zip -d /tmp \
    && dpkg -i /tmp/*.deb || apt-get install -fy \
    && rm -rf /tmp/rustscan*

WORKDIR /lab
ENV PATH="/opt/dirsearch:${PATH}"

CMD ["sleep", "infinity"]
