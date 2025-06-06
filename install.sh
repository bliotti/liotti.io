#!/bin/bash

set -v
### INSTALL COMMAND
### /bin/bash -c "$(curl -fsSL https://liotti.io/install.sh)"

# Check for Zsh installation, install if not present
if ! command -v zsh &>/dev/null; then
  echo "Zsh is not installed. Installing Zsh..."
  if [ "$(uname)" == "Darwin" ]; then
    # macOS installation
    sudo apt install zsh
  elif [ -f /etc/debian_version ]; then
    # Debian/Ubuntu installation
    sudo apt update && sudo apt install -y zsh
  elif [ -f /etc/redhat-release ]; then
    # RHEL/Fedora/CentOS installation
    sudo yum install -y zsh
  else
    echo "Unsupported OS. Please install Zsh manually."
    exit 1
  fi
fi

# Verify Zsh was installed correctly
if ! command -v zsh &>/dev/null; then
  echo "Failed to install Zsh. Please install it manually."
  exit 1
fi

echo "Zsh is installed."

# Check for Git installation, install if not present
if ! command -v git &>/dev/null; then
  echo "Git is not installed. Installing Git..."
  if [ "$(uname)" == "Darwin" ]; then
    # macOS installation
    brew install git
  elif [ -f /etc/debian_version ]; then
    # Debian/Ubuntu installation
    sudo apt update && sudo apt install -y git
  elif [ -f /etc/redhat-release ]; then
    # RHEL/Fedora/CentOS installation
    sudo yum install -y git
  else
    echo "Unsupported OS. Please install Git manually."
    exit 1
  fi
fi

# Verify Git was installed correctly
if ! command -v git &>/dev/null; then
  echo "Failed to install Git. Please install it manually."
  exit 1
fi

echo "Git is installed."

# Install Oh My Zsh without launching a new shell
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh is already installed."
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# INSTALL PLUGINS

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
else
  echo "zsh-autosuggestions is already installed."
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
else
  echo "zsh-syntax-highlighting is already installed."
fi

# zsh-fast-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
else
  echo "fast-syntax-highlighting is already installed."
fi

# zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
else
  echo "zsh-completions is already installed."
fi

# K
if [ ! -d "$ZSH_CUSTOM/plugins/k" ]; then
  git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
else
  echo "k is already installed."
fi

# Theme
if [ ! -d "$HOME/.oh-my-zsh/themes/passion.zsh-theme" ]; then
  git clone https://github.com/ChesterYue/ohmyzsh-theme-passion
  cp ./ohmyzsh-theme-passion/passion.zsh-theme ~/.oh-my-zsh/themes/passion.zsh-theme
else
  echo "Theme passion is already installed."
fi

# Define the .zshrc file location (you can adjust this path if needed)
ZSHRC_FILE="$HOME/.zshrc"

# Create a backup of the .zshrc file if it doesn't already exist
if [ ! -f "$ZSHRC_FILE.bak" ]; then
  cp "$ZSHRC_FILE" "$ZSHRC_FILE.bak"
fi

# Update the plugins line
sed -i -e '/^plugins=(/c\
plugins=(\
  git\
  k\
  zsh-autosuggestions\
  zsh-syntax-highlighting\
  fast-syntax-highlighting\
)' "$ZSHRC_FILE"

# Update the ZSH_THEME line
sed -i -e '/^ZSH_THEME=/c\ZSH_THEME="passion"' "$ZSHRC_FILE"

# Append the fpath part right before "source $ZSH/oh-my-zsh.sh" if it does not already exist
if ! grep -q 'fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' "$ZSHRC_FILE"; then
  sed -i -e '/^source \$ZSH\/oh-my-zsh.sh/i\
fpath+=\${ZSH_CUSTOM:-\${ZSH:-~\/.oh-my-zsh}\/custom}\/plugins\/zsh-completions\/src\
' "$ZSHRC_FILE"
fi

# Inform the user
echo "The plugins line has been updated in $ZSHRC_FILE. A backup has been created as $ZSHRC_FILE.bak."

# Automatically change default shell to Zsh without prompting
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing your default shell to Zsh..."
  chsh -s "$(which zsh)" "$USER"
  echo "Default shell changed to Zsh. Please restart your terminal or log out and log back in."
fi

set +v

# Prompt the user to switch to Zsh manually
echo "Installation complete! Please run 'zsh' to switch to Zsh and load your updated configuration."
