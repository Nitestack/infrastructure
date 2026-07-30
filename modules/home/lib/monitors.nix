# ╭──────────────────────────────────────────────────────────╮
# │ Shared default-monitor derivation from meta.monitors      │
# ╰──────────────────────────────────────────────────────────╯
{ monitors }:
let
  defaultMonitors = builtins.filter (monitor: monitor.isDefault) monitors;
  defaultMonitorCount = builtins.length defaultMonitors;
in
{
  inherit defaultMonitorCount;
  defaultMonitor = if defaultMonitorCount == 1 then builtins.head defaultMonitors else null;
}
