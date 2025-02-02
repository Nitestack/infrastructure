# ╭──────────────────────────────────────────────────────────╮
# │ wlogout                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  theme,
  ...
}:
let
  hibernate-icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/wlogout/mocha/blue/hibernate.svg";
    sha256 = "0c21kzvxplx1x85c1lkdhyix1sn4yb694g01l8xrxzfld8n367lp";
  };
  lock-icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/wlogout/mocha/blue/lock.svg";
    sha256 = "01hfrz1ifmfvkzj2fp1j5p28hgzjc1ghnya63f2p90csyxjjxg58";
  };
  logout-icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/wlogout/mocha/blue/logout.svg";
    sha256 = "15ixlfxnw13g247vf6nrwn5g9p5sr6cks3ind3rg50gb4hdgfnr7";
  };
  reboot-icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/wlogout/mocha/blue/reboot.svg";
    sha256 = "0qa6y74vq7rds5c7r8mw1klk0251ap8y1bkcwxhakb7lw8fgi07c";
  };
  shutdown-icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/wlogout/mocha/blue/shutdown.svg";
    sha256 = "0prq4wf0jx81dd2w74w3m6ayhjjf95b1lybyc8kchmcxs8blr8s6";
  };
  suspend-icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/wlogout/mocha/blue/suspend.svg";
    sha256 = "0swgd465zc2h7q9y1piw5mk5hmz54qws943wrxfqwpsqn4g5apj4";
  };
in
{
  programs.wlogout = {
    enable = true;
    style =
      let
        inherit (theme.variables)
          accentBgColor
          windowBgColor
          windowFgColor
          viewFgColor
          viewBgColor
          headerbarBorderColor
          ;
      in
      ''
        * {
          background-image: none;
          box-shadow: none;
        }

        window {
          background-color: ${windowBgColor};
        }

        button {
          border-radius: 0;
          border-color: ${accentBgColor};
          text-decoration-color: ${windowFgColor};
          color: ${viewFgColor};
          background-color: ${viewBgColor};
          border-style: solid;
          border-width: 1px;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
        }

        button:focus, button:active, button:hover {
          background-color: ${headerbarBorderColor};
          outline-style: none;
        }

        #lock {
          background-image: url("${lock-icon}");
        }

        #logout {
          background-image: url("${logout-icon}");
        }

        #suspend {
          background-image: url("${suspend-icon}");
        }

        #hibernate {
          background-image: url("${hibernate-icon}");
        }

        #shutdown {
          background-image: url("${shutdown-icon}");
        }

        #reboot {
          background-image: url("${reboot-icon}");
        }
      '';
  };
}
