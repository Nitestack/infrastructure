# ╭──────────────────────────────────────────────────────────╮
# │ Git                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  meta,
  flake,
  ...
}:
let
  inherit (meta) git;
  inherit (flake) inputs;
in
{
  programs = {
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };
    git = {
      enable = true;
      settings = {
        alias.count-lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
        user = {
          name = git.userName;
          email = git.userEmail;
        };
        core = {
          editor = "nvim";
          longpaths = true;
        };
        color.ui = true;
        pull.rebase = true;
        merge = {
          autoStash = true;
          conflictstyle = "zdiff3";
        };
        rebase.autoStash = true;
        push.autoSetupRemote = true;
        init.defaultBranch = "main";
      };
      signing = {
        key = git.userEmail;
        format = "openpgp";
        signByDefault = true;
      };
      includes = [
        { path = "${inputs.catppuccin-delta}/catppuccin.gitconfig"; }
      ];
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        dark = true;
        features = "catppuccin-mocha";
        line-numbers = true;
        navigate = true;
        side-by-side = true;
      };
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          AddKeysToAgent = "yes";
          Compression = false;
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          ForwardAgent = "no";
          HashKnownHosts = "no";
          ServerAliveCountMax = 3;
          ServerAliveInterval = 0;
          UserKnownHostsFile = "~/.ssh/known_hosts";
        };
        "raspberrypi" = {
          hostname = "npham.de";
          user = meta.username;
        };
      };
    };
  };
}
