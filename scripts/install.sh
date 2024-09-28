#!/usr/bin/env bash

set -uo pipefail

TARGET="${HOME}/.dotfiles"
BRANCH=${BRANCH:-"master"}

## Set remote depending on the ssh flag
if [[ -n "${SSH-}" ]]; then
  remote="git@github.com:Nitestack/dotfiles.git"
else
  remote="https://github.com/Nitestack/dotfiles.git"
fi

## Check if dotfiles are already downloaded
if [[ -d "${TARGET}" ]]; then
  path=$(realpath "${TARGET}")
  git="git -C ${path}"

  ## Ensure that the remote is set to the correct URL
  if ${git} remote | grep -q "^origin$"; then
    ${git} remote set-url origin "${remote}"
  else
    ${git} remote add origin "${remote}"
  fi
  ${git} checkout -B "${BRANCH}"
  ${git} fetch origin "${BRANCH}"
  ${git} reset --hard FETCH_HEAD
  ${git} clean -fdx
else
  git clone -b "${BRANCH}" "${remote}" "${TARGET}"
fi

# NixOS only: initialize system
if command -v "nixos-version" &>/dev/null; then
  sudo nixos-rebuild switch --flake "${TARGET}/nix#nixstation" --impure
fi

set -- --source="${TARGET}" --verbose=false

if [[ -n "${ONE_SHOT-}" ]]; then
  set -- "$@" --one-shot
else
  set -- "$@" --apply
fi

chezmoi init "$@"
