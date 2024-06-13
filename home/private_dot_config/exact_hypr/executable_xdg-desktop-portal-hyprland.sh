#!/usr/bin/env bash

# ╭──────────────────────────────────────────────────────────╮
# │ XDG DESKTOP PORTAL HYPRLAND                              │
# ╰──────────────────────────────────────────────────────────╯
# https://wiki.hyprland.org/Useful-Utilities/xdg-desktop-portal-hyprland/#usage

sleep 1
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2
/usr/lib/xdg-desktop-portal &
