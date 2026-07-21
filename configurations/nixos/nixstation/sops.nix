{
  config,
  flake,
  ...
}:
let
  inherit (flake) inputs;
in
{
  # TODO(user): nixstation has no age key registered in .sops.yaml yet —
  # run `nix run nixpkgs#ssh-to-age -- -i ~/.ssh/id_ed25519.pub` on this
  # host and paste the result over the `nixstation_ssh` placeholder in
  # .sops.yaml, then declare secrets here (see modules/home/pi/NOTES.md).
  imports = [ inputs.sops-nix.nixosModules.sops ];

  config.sops = {
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/home/${config.meta.username}/.ssh/id_ed25519" ];
  };
}
