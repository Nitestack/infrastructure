{
  # Brings custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # Change versions, add patches, set compilation flags, ...
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
  };
}
