#!/bin/zsh

echo "zsh: Setting up Spaceship theme..."

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
target_path="$ZSH_CUSTOM/themes/spaceship.zsh-theme"
symlink_path="$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme"

# Check if the path exists
if [[ ! -e "$symlink_path" ]]; then
  echo "     Spaceship theme not found. Skipping."
  return
fi

# Check if the symbolic link already exists
if [[ -L "$target_path" ]]; then
  echo "     Symbolic link for Spaceship theme already exists. Skipping."
  return
fi

ln -s "$symlink_path" "$target_path"

echo "     Symbolic link for Spaceship theme created."
echo "     $symlink_path -> $target_path"
