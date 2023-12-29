#!/bin/zsh

echo "zsh: Setting up Spaceship theme..."

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
symlink_path="$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme"

# Check if the symbolic link doesn't exist
if [[ ! -e "$symlink_path" ]]; then
  target_path="$ZSH_CUSTOM/themes/spaceship.zsh-theme"

  ln -s "$symlink_path" "$target_path"

  echo "     Symbolic link for Spaceship theme created."
  echo "     $symlink_path -> $target_path"
else
  echo "     Symbolic link for Spaceship theme already exists. Skipping."
fi
