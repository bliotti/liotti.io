#!/bin/bash

### INSTALL COMMAND
### /bin/bash -c "$(curl -fsSL https://coinguy.io/install.sh)"

# Check for Zsh installation, install if not present
if ! command -v zsh &>/dev/null; then
  echo "Zsh is not installed. Installing Zsh..."
  if [ "$(uname)" == "Darwin" ]; then
    # macOS installation
    brew install zsh
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

# Install Oh My Zsh without launching a new shell
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Install plugins
# autosuggestions plugin
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
# zsh-syntax-highlighting plugin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
# zsh-fast-syntax-highlighting plugin
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
# zsh-autocomplete plugin
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete

# Define the .zshrc file location (you can adjust this path if needed)
ZSHRC_FILE="$HOME/.zshrc"

# Use sed to find and replace the plugins line
sed -i.bak '/^plugins=(git)/c\
plugins=(\
  git\
  zsh-autosuggestions\
  zsh-syntax-highlighting\
  fast-syntax-highlighting\
  zsh-autocomplete\
)' "$ZSHRC_FILE"

# Inform the user
echo "The plugins line has been updated in $ZSHRC_FILE. A backup has been created as $ZSHRC_FILE.bak."

# Source the updated .zshrc
source $ZSHRC_FILE
