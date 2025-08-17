{ pkgs, lib, ... }:
{
  scss = import ./scss.nix {
    inherit pkgs lib;
  };
}
