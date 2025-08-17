# ╭──────────────────────────────────────────────────────────╮
# │ Git                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  meta,
  pkgs,
  ...
}:
let
  inherit (meta) git;

  catppuccin-repo = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "delta";
    rev = "7b06b1f174c03f53ff68da1ae1666ca3ef7683ad";
    sha256 = "1qkqchyj4dn0w4wq5xhc86dpj0vlmn94n814nzzif8y7rj3g8w0w";
  };
in
{
  programs = {
    git = {
      inherit (git) userName userEmail;

      enable = true;
      signing = {
        key = git.userEmail;
        format = "openpgp";
        signByDefault = true;
      };
      extraConfig = {
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
      delta = {
        enable = true;
        options = {
          dark = true;
          features = "catppuccin-mocha";
          line-numbers = true;
          navigate = true;
          side-by-side = true;
        };
      };
      aliases.count-lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
      includes = [
        { path = "${catppuccin-repo}/catppuccin.gitconfig"; }
      ];
    };
    ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };
  };
}
