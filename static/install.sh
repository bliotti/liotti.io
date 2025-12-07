#!/usr/bin/env bash
#
# liotti.io zsh / oh-my-zsh + Neovim bootstrap installer
# Safe by default, idempotent, cross-platform (macOS + Linux)

########################################
# Interactive confirmation (AUTO_YES=1 ok)
########################################

if [ "${AUTO_YES:-}" != "1" ]; then
  cat <<'EOF'
This installer will:

  • Install system packages (curl, zsh, git, bc)
  • Install Neovim
  • Install Oh My Zsh into ~/.oh-my-zsh
  • Install and enable Zsh plugins:
      - zsh-autosuggestions
      - zsh-syntax-highlighting
      - fast-syntax-highlighting
      - zsh-completions
      - k
  • Install and enable the "passion" Oh My Zsh theme
  • Configure Neovim from your repo:
      - Clone or update bliotti/nvim into ~/.config/nvim
      - Back up existing ~/.config/nvim to ~/.config/nvim.bak (once)
  • Back up ~/.zshrc to ~/.zshrc.bak (once)
  • Modify ~/.zshrc:
      - set ZSH_THEME
      - set plugin list
      - add zsh-completions fpath
      - add disk aliases (dirdisk, dusort)
  • Attempt to change your default shell to zsh (best effort)

No files outside your home directory are modified except via
your system package manager.

EOF

  read -r -p "Type 'yes' to continue, anything else to abort: " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Installation aborted."
    exit 0
  fi
fi

echo "Proceeding with installation..."

########################################
# Strict mode + trace
########################################
set -euo pipefail
set -v

########################################
# Helpers
########################################

OS="$(uname -s)"

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_pkg() {
  local pkg="$1"

  if have_cmd "$pkg"; then
    return 0
  fi

  echo "Installing ${pkg}..."

  case "$OS" in
    Darwin)
      if ! have_cmd brew; then
        echo "Homebrew not found. Install from https://brew.sh and rerun."
        exit 1
      fi
      brew install "$pkg"
      ;;
    Linux)
      if [ -f /etc/debian_version ]; then
        sudo apt update
        sudo apt install -y "$pkg"
      elif [ -f /etc/redhat-release ]; then
        sudo yum install -y "$pkg"
      else
        echo "Unsupported Linux distro. Install ${pkg} manually."
        exit 1
      fi
      ;;
    *)
      echo "Unsupported OS: ${OS}. Install ${pkg} manually."
      exit 1
      ;;
  esac
}

# portable sed -i (GNU vs BSD)
sedi() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

########################################
# Neovim installer helper
########################################
install_nvim() {  # ### ADDED: Neovim
  if have_cmd nvim; then
    echo "Neovim already installed (nvim found)."
    return 0
  fi

  echo "Installing Neovim..."

  case "$OS" in
    Darwin)
      if ! have_cmd brew; then
        echo "Homebrew not found. Install from https://brew.sh and rerun."
        exit 1
      fi
      brew install neovim
      ;;
    Linux)
      if [ -f /etc/debian_version ]; then
        sudo apt update
        sudo apt install -y neovim
      elif [ -f /etc/redhat-release ]; then
        sudo yum install -y neovim
      else
        echo "Unsupported Linux distro. Install Neovim manually."
        exit 1
      fi
      ;;
    *)
      echo "Unsupported OS: ${OS}. Install Neovim manually."
      exit 1
      ;;
  esac
}

########################################
# 1. Core tools (curl first)
########################################

install_pkg curl
install_pkg zsh
install_pkg git
install_pkg bc
install_pkg build-essential
install_nvim   # ### ADDED: Neovim

########################################
# 2. Oh My Zsh
########################################

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSHRC_FILE="$HOME/.zshrc"

# Ensure .zshrc exists
if [ ! -f "$ZSHRC_FILE" ]; then
  cat >"$ZSHRC_FILE" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
EOF
fi

########################################
# 3. Backup .zshrc
########################################

if [ ! -f "$ZSHRC_FILE.bak" ]; then
  cp "$ZSHRC_FILE" "$ZSHRC_FILE.bak"
fi

########################################
# 4. Plugins
########################################

clone_plugin() {
  local name="$1"
  local repo="$2"

  if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
    git clone "$repo" "$ZSH_CUSTOM/plugins/$name"
  else
    echo "$name already installed."
  fi
}

clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
clone_plugin fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting
clone_plugin zsh-completions https://github.com/zsh-users/zsh-completions
clone_plugin k https://github.com/supercrabtree/k

########################################
# 5. Passion theme
########################################

THEME_FILE="$HOME/.oh-my-zsh/themes/passion.zsh-theme"
if [ ! -f "$THEME_FILE" ]; then
  TMP_THEME="$(mktemp -d)"
  git clone https://github.com/ChesterYue/ohmyzsh-theme-passion "$TMP_THEME"
  cp "$TMP_THEME/passion.zsh-theme" "$THEME_FILE"
  rm -rf "$TMP_THEME"
else
  echo "Passion theme already installed."
fi

########################################
# 6. Update .zshrc
########################################

sedi 's/^ZSH_THEME=.*/ZSH_THEME="passion"/' "$ZSHRC_FILE"
sedi 's/^plugins=.*/plugins=(git k zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)/' "$ZSHRC_FILE"

########################################
# 7. zsh-completions fpath
########################################

if ! grep -q 'zsh-completions/src' "$ZSHRC_FILE"; then
  sedi '/^source \$ZSH\/oh-my-zsh\.sh/i\
fpath+=\${ZSH_CUSTOM:-\${ZSH:-~\/.oh-my-zsh}\/custom}\/plugins\/zsh-completions\/src
' "$ZSHRC_FILE"
fi

########################################
# 8. Disk aliases
########################################

sedi '/^alias dirdisk=/d' "$ZSHRC_FILE"
sedi '/^alias dusort=/d' "$ZSHRC_FILE"

cat >>"$ZSHRC_FILE" <<'EOF'
alias dirdisk='df -h | awk "NR==1 {print; next} {print | \"sort -k4 -h -r\"}"'
alias dusort='du -sh * | sort -rh'
EOF

########################################
# 9. Change default shell
########################################

ZSH_PATH="$(command -v zsh || true)"
if [ -n "$ZSH_PATH" ] && [ "${SHELL:-}" != "$ZSH_PATH" ]; then
  chsh -s "$ZSH_PATH" "$USER" || true
fi

########################################
# 10. Neovim config from bliotti/nvim
########################################

NVIM_REPO="${NVIM_REPO:-https://github.com/bliotti/nvim}"   # ### ADDED
NVIM_CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"        # ### ADDED
NVIM_CONFIG_DIR="$NVIM_CONFIG_ROOT/nvim"                    # ### ADDED
NVIM_CONFIG_BAK="$NVIM_CONFIG_DIR.bak"                      # ### ADDED

mkdir -p "$NVIM_CONFIG_ROOT"

if [ -d "$NVIM_CONFIG_DIR" ]; then
  if [ -d "$NVIM_CONFIG_DIR/.git" ]; then
    # If it's a git repo, check remote; if it's your repo, just pull.
    remote_url="$(git -C "$NVIM_CONFIG_DIR" config --get remote.origin.url || true)"
    if [ "$remote_url" = "$NVIM_REPO" ]; then
      echo "Updating existing Neovim config in $NVIM_CONFIG_DIR..."
      git -C "$NVIM_CONFIG_DIR" pull --ff-only || true
    else
      echo "Existing Neovim config found at $NVIM_CONFIG_DIR (remote: $remote_url)"
      if [ ! -d "$NVIM_CONFIG_BAK" ]; then
        echo "Backing up Neovim config to $NVIM_CONFIG_BAK"
        mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_BAK"
      else
        echo "Backup $NVIM_CONFIG_BAK already exists; leaving existing config in place."
      fi
      if [ ! -d "$NVIM_CONFIG_DIR" ]; then
        echo "Cloning Neovim config from $NVIM_REPO"
        git clone "$NVIM_REPO" "$NVIM_CONFIG_DIR"
      fi
    fi
  else
    # Non-git directory
    echo "Existing non-git Neovim config directory at $NVIM_CONFIG_DIR"
    if [ ! -d "$NVIM_CONFIG_BAK" ]; then
      echo "Backing up Neovim config to $NVIM_CONFIG_BAK"
      mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_BAK"
      echo "Cloning Neovim config from $NVIM_REPO"
      git clone "$NVIM_REPO" "$NVIM_CONFIG_DIR"
    else
      echo "Backup $NVIM_CONFIG_BAK already exists; leaving existing config in place."
    fi
  fi
else
  echo "Cloning Neovim config from $NVIM_REPO into $NVIM_CONFIG_DIR"
  git clone "$NVIM_REPO" "$NVIM_CONFIG_DIR"
fi

set +v
echo "Installation complete. Open a new terminal or run: zsh"
