# ╭──────────────────────────────────────────────────────────╮
# │ GIT                                                      │
# ╰──────────────────────────────────────────────────────────╯

let
  githubUsername = "Nitestack";
in
{
  programs.git = {
    enable = true;
    userName = githubUsername;
    userEmail = "74626967+${githubUsername}@users.noreply.github.com";
    extraConfig = {
      core = {
        editor = "nvim";
        pager = "delta";
      };
      push.autoSetupRemote = true;
      pull.rebase = true;
      merge.autoStash = true;
      rebase.autoStash = true;
      init.defaultBranch = "main";
      color.ui = true;
    };
  };
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
  services.ssh-agent.enable = true;

}
