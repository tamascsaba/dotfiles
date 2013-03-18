#!/usr/bin/env bash
# vim: set syntax=sh:

set -e

echo ''

# Colors :)
bold="$(tput bold)"
reset="$(tput sgr0)"
red="$(tput setaf 1)"
yellow="$(tput setaf 3)"
green="$(tput setaf 2)"

function message {
  echo -e "${bold}${1}[${2}]${reset}\t\t${bold}${3}${reset}"
}

function fail {
  message $red "FAIL" $1
  echo ''
  exit
}

function success {
  message $green "OK" $1
}

function warn {
  local hashes=$(head -c (${#1} + 4) < /dev/zero | tr '\0' '#')
  echo -e "\n${hashes}\n# ${bold}${yellow}${1}${reset} #\n${hashes}"
}

# Sets the current directory to $DIR
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function download {
  # Download the url passed as an argument and install it
  curl -L ${1} | sh
}

function link {
  ln -s "${DIR}/${1}" "${HOME}"
}

function install_powerline {
  warn "Installing Powerline" &&

  sudo pip install "git+git://github.com/Lokaltog/powerline" &&

  success "Installed Powerline" || fail "Could not install Powerline"
}

function install_janus {
  local pre_reqs="ruby-dev rake exuberant-ctags ack-grep vim"
  local url="https://bit.ly/janus-bootstrap"

  warn "Installing Janus"

  # Install the pre-requisites
  sudo apt-get install $pre_reqs &&

  # Delete existing vim files
  rm -rf "${HOME}/.vim" "${HOME}/.vimrc" &&

  # Download and install using the janus boostrap script
  download $url &&

  # Symlink janus and vim configuration files
  link ".janus/" &&
  link ".vimrc.before" &&
  link ".vimrc.after" &&

  success "Installed Janus" || fail "Could not install Janus"
}

function install_tmux {
  warn "Installing Tmux"

  # Install the package
  sudo apt-get install tmux &&

  # Symlink the config
  link ".tmux.conf" &&

  success "Installed Tmux" || fail "Could not install Tmux"
}

function install_zsh {
  local pre_reqs="zsh"
  local url="https://goo.gl/1DRPI"

  warn "Installing ZSH"

  # Install the pre-requisites
  sudo apt-get install $pre_reqs &&

  # Download and install using the oh-my-zsh bootstrap script
  download $url &&

  # Substitude the default .zshrc for our customized one
  rm -f "${HOME}/.zshrc" &&
  link ".zshrc" &&

  # Set this user's default shell to ZSH
  chsh -s /bin/zsh &&

  success "Installed ZSH" || fail "Could not install ZSH"
}

function install_extra {
  warn "Setting up config files"

  # Create the symlinks
  link ".gitconfig"
}


install_powerline
install_janus
install_zsh
install_tmux
install_extra