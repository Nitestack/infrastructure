# ╭──────────────────────────────────────────────────────────╮
# │ Spicetify                                                │
# ╰──────────────────────────────────────────────────────────╯
{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        autoSkipVideo
        # beautifulLyrics
        listPlaylistsWithSong
        shuffle
      ];
      enabledCustomApps = with spicePkgs.apps; [
        lyricsPlus
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
