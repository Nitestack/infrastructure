; ╭──────────────────────────────────────────────────────────╮
; │ KOMOREBI AUTOHOTKEY CONFIG                               │
; ╰──────────────────────────────────────────────────────────╯

#Requires AutoHotkey v2.0.2
#SingleInstance Force

Komorebic(cmd) {
    RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

; ── General ───────────────────────────────────────────────────────────
^+r:: Komorebic("reload-configuration")

; ── Apps ──────────────────────────────────────────────────────────────
#\:: Run "wezterm-gui.exe"
#w:: Run "Arc.exe"

; ── Windows ───────────────────────────────────────────────────────────

; Move focus
#h:: Komorebic("focus left")
#j:: Komorebic("focus down")
#k:: Komorebic("focus up")
#l:: Komorebic("focus right")

; Resize windows
#m:: Komorebic("toggle-maximize")
#Left:: Komorebic("resize-edge left increase")
#Right:: Komorebic("resize-edge right increase")
#Up:: Komorebic("resize-edge up increase")
#Down:: Komorebic("resize-edge down increase")

; Move windows
#!h:: Komorebic("move left")
#!j:: Komorebic("move down")
#!k:: Komorebic("move up")
#!l:: Komorebic("move right")

#q:: Komorebic("close")

: Toggling
#r:: Komorebic("cycle-layout next")
#t:: Komorebic("toggle-float")
+#t:: Komorebic("toggle-pause")

; Workspaces
#1:: Komorebic("focus-workspace 0")
#2:: Komorebic("focus-workspace 1")
#3:: Komorebic("focus-workspace 2")
#4:: Komorebic("focus-workspace 3")
#5:: Komorebic("focus-workspace 4")
#6:: Komorebic("focus-workspace 5")
#7:: Komorebic("focus-workspace 6")
#8:: Komorebic("focus-workspace 7")
#9:: Komorebic("focus-workspace 8")
#0:: Komorebic("focus-workspace 9")
^#l:: Komorebic("cycle-workspace next")
^#h:: Komorebic("cycle-workspace previous")
#WheelUp:: Komorebic("cycle-workspace next")
#WheelDown:: Komorebic("cycle-workspace previous")

; Move windows across workspaces
#+1:: Komorebic("move-to-workspace 0")
#+2:: Komorebic("move-to-workspace 1")
#+3:: Komorebic("move-to-workspace 2")
#+4:: Komorebic("move-to-workspace 3")
#+5:: Komorebic("move-to-workspace 4")
#+6:: Komorebic("move-to-workspace 5")
#+7:: Komorebic("move-to-workspace 6")
#+8:: Komorebic("move-to-workspace 7")
#+9:: Komorebic("move-to-workspace 8")
#+0:: Komorebic("move-to-workspace 9")
#+l:: Komorebic("cycle-move-to-workspace next")
#+h:: Komorebic("cycle-move-to-workspace previous")
