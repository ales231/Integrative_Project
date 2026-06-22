FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server sudo \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/sshd

RUN useradd -m -s /bin/bash labuser \
    && echo "labuser:changeme" | chpasswd \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
