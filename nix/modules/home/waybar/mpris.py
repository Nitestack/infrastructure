#!/usr/bin/env python3

import subprocess
import time
import json

PLAYER_ICONS = {
    "firefox": "",
    "spotify": "",
    "youtube": "󰗃",
    "default": "",
}
STATUS_ICONS = {
    "Playing": "",
    "Paused": "",
    "Stopped": "",
    "default": "",
}

REFRESH_INTERVAL = 0.5
MAX_LEN = 40


def run_cmd(cmd, default=""):
    try:
        return subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
    except subprocess.CalledProcessError:
        return default


def get_player_status():
    return run_cmd(["playerctl", "status"], "Stopped")


def get_player_service():
    output = run_cmd(["playerctl", "-l"], "default")
    players = [line for line in output.splitlines() if line.strip()]
    return players[0] if players else "default"


def get_player_name():
    url = run_cmd(["playerctl", "metadata", "xesam:url"], "default")
    for key, _ in PLAYER_ICONS.items():
        if key.lower() in url.lower():
            return key
    return get_player_service()


def get_position():
    pos = run_cmd(["playerctl", "position"], "0")
    length = run_cmd(["playerctl", "metadata", "mpris:length"], "0")
    try:
        p = float(pos)
        len = float(length) / 1e6
        return (
            f"{int(p//60):02d}:{int(p%60):02d} / {int(len//60):02d}:{int(len%60):02d}"
        )
    except:  # noqa: E722
        return ""


def get_title():
    return run_cmd(["playerctl", "metadata", "title"], "Unknown Title")


def get_artist():
    return run_cmd(["playerctl", "metadata", "artist"], "Unknown Artist")


def get_metadata():
    player = get_player_name()
    title = get_title()
    artist = get_artist()
    status = get_player_status()
    return title, artist, status, player


def pick_icon(name, mapping):
    return mapping[name] if name in mapping else mapping["default"]


if __name__ == "__main__":
    scroll_offset = 0

    # initial metadata
    title, artist, status, player = get_metadata()
    text = f"{title} - {artist}"
    length = len(text)

    while True:
        # Metadata Refresh
        new_title, new_artist, new_status, new_player = get_metadata()
        if (new_title, new_artist, new_status, new_player) != (
            title,
            artist,
            status,
            player,
        ):
            title, artist, status, player = (
                new_title,
                new_artist,
                new_status,
                new_player,
            )
            text = f"{title} - {artist}"
            length = len(text)
            # Reset scroll offset on change
            if (title, artist, player) != (new_title, new_artist, new_player):
                scroll_offset = 0
        pos = get_position()

        # Scrolling Text
        loop_separator = "   "
        scrolling_text = text + loop_separator + text
        if length > MAX_LEN:
            # always grab MAX_LEN chars from scrolling_text, wrapping seamlessly
            start = scroll_offset % (length + len(loop_separator))
            display = f" {scrolling_text[start : start + MAX_LEN]}"
            scroll_offset = (scroll_offset + 1) % (length + len(loop_separator))
        else:
            display = text

        icon_status = pick_icon(status, STATUS_ICONS)

        out = {
            "class": player if status.lower() == "playing" else status,
            "text": f"{pick_icon(player, PLAYER_ICONS) if status.lower() == "playing" else icon_status} {display}",
            "tooltip": f"{icon_status} {pos}",
        }
        print(json.dumps(out), end="\n")

        time.sleep(REFRESH_INTERVAL)
