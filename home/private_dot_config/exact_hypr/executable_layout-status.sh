#!/usr/bin/env bash

# ╭──────────────────────────────────────────────────────────╮
# │ LAYOUT STATUS                                            │
# ╰──────────────────────────────────────────────────────────╯

layout="$(bat /etc/vconsole.conf | grep XKBLAYOUT | awk -F'=' '{print toupper($2)}')"
printf "%s   " "${layout}"
