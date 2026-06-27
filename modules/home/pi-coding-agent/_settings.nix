# Common pi-coding-agent settings shared by all hosts.
# Does NOT include defaultProvider — set that per-host.
{
  theme = "catppuccin-mocha";
  quietStartup = true;
  compaction = {
    enabled = true;
    reserveTokens = 16384;
    keepRecentTokens = 20000;
  };
  retry = {
    enabled = true;
    maxRetries = 3;
    baseDelayMs = 2000;
  };
  packages = [
    "npm:@hypabolic/pi-hypa"
    "npm:pi-hermes-memory"
    "npm:pi-lens"
    "npm:pi-simplify"
    "npm:@plannotator/pi-extension"
    "npm:@juicesharp/rpiv-todo"
    "npm:@juicesharp/rpiv-ask-user-question"
    "npm:@juicesharp/rpiv-advisor"
    "npm:@juicesharp/rpiv-btw"
    "npm:@ayulab/pi-rewind"
    "npm:pi-catppuccin-tui"
    "npm:pi-catppuccin-footer"
    "npm:@juicesharp/rpiv-pi"
    "npm:@tintinweb/pi-subagents"
    "npm:@juicesharp/rpiv-i18n"
    "npm:@juicesharp/rpiv-web-tools"
    "npm:@juicesharp/rpiv-args"
    "npm:@juicesharp/rpiv-workflow"
  ];
}
