# ╭──────────────────────────────────────────────────────────╮
# │ Git                                                      │
# ╰──────────────────────────────────────────────────────────╯
let
  githubUsername = "Nitestack";
in
{
  programs.git = {
    enable = true;
    userName = githubUsername;
    userEmail = "74626967+${githubUsername}@users.noreply.github.com";
    aliases = {
      count-lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
    };
    extraConfig = {
      core.editor = "nvim";
      push.autoSetupRemote = true;
      pull.rebase = true;
      merge.autoStash = true;
      rebase.autoStash = true;
      init.defaultBranch = "main";
      color.ui = true;
    };
    delta.enable = true;
  };
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
  services.ssh-agent.enable = true;
}
