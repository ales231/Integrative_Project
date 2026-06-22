#!/bin/bash
set -euo pipefail
python3 /opt/flask-app/app.py &
nginx -g 'daemon off;'
