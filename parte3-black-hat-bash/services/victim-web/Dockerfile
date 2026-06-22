FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx python3 python3-flask \
    && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/sites-available/default
COPY wp-static/ /var/www/html/
COPY flask-app/ /opt/flask-app/
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80 8081
CMD ["/start.sh"]
