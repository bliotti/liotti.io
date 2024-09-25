#!/bin/bash

# Check for root/sudo permissions
# if [ "$EUID" -ne 0 ]
#   then echo "Please run as root or use sudo"
#   exit
# fi

# Install Oh my ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
# autosuggesions plugin
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
