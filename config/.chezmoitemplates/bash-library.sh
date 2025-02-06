# shellcheck shell=bash
# ╭──────────────────────────────────────────────────────────╮
# │ Bash Library                                             │
# ╰──────────────────────────────────────────────────────────╯

set -uo pipefail

# ── Log ───────────────────────────────────────────────────────────────
_log_header() {
	gum format -- "# $1"
}

_log() {
	gum log -s "$@"
}

_spin() {
	title=$1
	shift

	gum spin --show-error --spinner points --title "${title}" "$@"
}
