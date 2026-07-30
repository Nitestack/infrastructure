# ╭──────────────────────────────────────────────────────────╮
# │ Spicetify                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  lib,
  meta,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  flavor = lib.toLower meta.catppuccinFlavor;
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = flavor;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        autoSkipVideo
        beautifulLyrics
        listPlaylistsWithSong
        shuffle
      ];
      enabledCustomApps = with spicePkgs.apps; [
        marketplace
      ];
      # nix eval --impure --json --expr 'builtins.attrNames ((builtins.getFlake "github:Gerg-L/spicetify-nix").legacyPackages.x86_64-linux.snippets)'
      enabledSnippets = with spicePkgs.snippets; [
        fullscreenHidePlayingFrom
        prettyLyrics
        removeTheArtistsAndCreditsSectionsFromTheSidebar
        queueTopSidePanel
      ];
    };
}
