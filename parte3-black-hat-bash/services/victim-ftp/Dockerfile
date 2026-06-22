FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    vsftpd apache2 git \
    && rm -rf /var/lib/apt/lists/*

COPY vsftpd.conf /etc/vsftpd.conf
COPY apache-backup.conf /etc/apache2/conf-available/backup.conf
COPY html/ /var/www/html/
COPY init-repos.sh /init-repos.sh

RUN chmod +x /init-repos.sh \
    && a2enconf backup \
    && a2enmod autoindex \
    && mkdir -p /var/run/vsftpd/empty

EXPOSE 21 80
CMD ["/bin/bash", "-c", "/init-repos.sh && service apache2 start && exec vsftpd /etc/vsftpd.conf"]
