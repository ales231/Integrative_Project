#!/bin/bash
set -euo pipefail

init_repo() {
    local dir="$1"
    local name="$2"
    local email="$3"

    mkdir -p "${dir}"
    echo "# ${dir}" > "${dir}/README.md"
    git -C "${dir}" init
    git -C "${dir}" config user.name "${name}"
    git -C "${dir}" config user.email "${email}"
    git -C "${dir}" add -A
    git -C "${dir}" commit -m "commit code"
}

init_repo /var/www/html/backup/acme-hyper-branding "Melissa Rogers" "mrogers@acme-hyper-branding.com"
init_repo /var/www/html/backup/acme-impact-alliance "Kevin Peterson" "kpeterson@acme-impact-alliance.com"

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Apache2 Ubuntu Default Page: It works</title></head>
<body><h1>Apache2 Ubuntu Default Page: It works</h1></body>
</html>
EOF

chown -R www-data:www-data /var/www/html
chmod -R a+rX /var/www/html
