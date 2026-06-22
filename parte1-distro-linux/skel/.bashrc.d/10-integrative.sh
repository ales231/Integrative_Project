# Mensaje y alias del proyecto integrador (cargado desde .bashrc)
alias ll='ls -alF'
alias nv='nvim'
alias c='code .'

if [[ -z "${INTEGRATIVE_WELCOME_SHOWN:-}" ]]; then
  export INTEGRATIVE_WELCOME_SHOWN=1
  echo "Bienvenido a la distro personalizada del proyecto integrador."
  echo "Herramientas: LibreWolf, Neovim, Visual Studio Code."
fi
