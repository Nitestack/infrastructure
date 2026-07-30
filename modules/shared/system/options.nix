{
  lib,
  pkgs,
  config,
  flake,
  ...
}:
let
  inherit (flake) inputs;
  inherit (lib.options) mkOption;
  inherit (lib.types)
    submodule
    str
    package
    listOf
    int
    float
    bool
    nullOr
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
  mkThemeOption = mkOption {
    type = submodule {
      options = {
        name = mkStringOption;
        package = mkPackageOption;
      };
    };
  };
in
{
  options = {
    meta = mkOption {
      type = submodule {
        options = {
          username = mkStringOption;
          description = mkStringOption;
          git = mkOption {
            type = submodule {
              options = {
                userName = mkStringOption;
                userEmail = mkStringOption;
              };
            };
          };
          font = mkOption {
            type = submodule {
              options = {
                sans = mkOption {
                  type = submodule {
                    options = {
                      name = mkStringOption;
                      titleName = mkOption {
                        type = str;
                        default = config.meta.font.sans.name;
                      };
                      package = mkPackageOption;
                    };
                  };
                };
                serif = mkOption {
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
          catppuccinFlavor = mkOption {
            type = lib.types.enum [
              "Latte"
              "Frappe"
              "Macchiato"
              "Mocha"
            ];
            description = "Catppuccin flavour, in the title case upstream themes use for display names. Lower-case it for package attrs and file names.";
          };
          gtkTheme = mkThemeOption;
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
          iconTheme = mkThemeOption;
          kvantumTheme = mkThemeOption;
          monitors = mkOption {
            default = [ ];
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
                  type = float;
                  default = 1.0;
                };
                isDefault = mkOption {
                  type = bool;
                  default = false;
                };
                backlight = mkOption {
                  type = nullOr (submodule {
                    options = {
                      i2cBus = mkStringOption;
                      busName = mkStringOption;
                      device = mkStringOption;
                    };
                  });
                  default = null;
                };
              };
            });
          };
          maxRefreshRate = lib.mkOption {
            type = int;
            default = lib.foldl' (
              max: monitor: if monitor.refreshRate > max then monitor.refreshRate else max
            ) 0 config.meta.monitors;
            readOnly = true;
          };
        };
      };
    };
    theme = mkOption {
      inherit (pkgs.formats.json { }) type;
    };
  };
  config = {
    meta = import ../../../meta.nix {
      inherit pkgs inputs;
    };
    theme = lib.importJSON ../../../theme.json;
  };
}
