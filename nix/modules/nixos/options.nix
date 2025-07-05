{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkOption;
  inherit (lib.types)
    submodule
    str
    package
    listOf
    int
    ;

  mkStringOption = mkOption {
    type = str;
  };
  mkIntOption = mkOption {
    type = int;
  };
  mkPackageOption = mkOption {
    type = package;
  };
in
{
  options = {
    meta = mkOption {
      type = submodule {
        options = {
          username = mkStringOption;
          description = mkStringOption;
          font = mkOption {
            type = submodule {
              options = {
                sans = mkOption {
                  type = submodule {
                    options = {
                      name = mkStringOption;
                      package = mkPackageOption;
                    };
                  };
                };
                nerd = mkOption {
                  type = submodule {
                    options = {
                      name = mkStringOption;
                      monoName = mkStringOption;
                      propoName = mkStringOption;
                      italic = mkOption {
                        type = submodule {
                          options = {
                            name = mkStringOption;
                            monoName = mkStringOption;
                            propoName = mkStringOption;
                          };
                        };
                      };
                      packages = mkOption {
                        type = listOf package;
                        default = [ ];
                      };
                    };
                  };
                };
                emoji = mkOption {
                  type = submodule {
                    options = {
                      name = mkStringOption;
                      package = mkPackageOption;
                    };
                  };
                };
              };
            };
          };
          gtkTheme = mkOption {
            type = submodule {
              options = {
                name = mkStringOption;
                package = mkPackageOption;
              };
            };
          };
          cursorTheme = mkOption {
            type = submodule {
              options = {
                name = mkStringOption;
                package = mkPackageOption;
                size = mkOption {
                  type = int;
                  default = 24;
                };
              };
            };
          };
          iconTheme = mkOption {
            type = submodule {
              options = {
                name = mkStringOption;
                package = mkPackageOption;
              };
            };
          };
          kvantumTheme = mkOption {
            type = submodule {
              options = {
                name = mkStringOption;
                package = mkPackageOption;
              };
            };
          };
          monitors = mkOption {
            type = listOf (submodule {
              options = {
                name = mkStringOption;
                resolution = mkStringOption;
                refreshRate = mkIntOption;
                position = mkOption {
                  type = submodule {
                    options = {
                      x = mkIntOption;
                      y = mkOption {
                        type = int;
                        default = 0;
                      };
                    };
                  };
                };
                scale = mkOption {
                  type = int;
                  default = 1;
                };
              };
            });
          };
        };
      };
    };
    theme = mkOption {
      type = (pkgs.formats.json { }).type;
    };
  };
  config = {
    meta = import ../../meta.nix {
      pkgs = pkgs;
    };
    theme = builtins.fromJSON (builtins.readFile ../../theme.json);
  };
}
