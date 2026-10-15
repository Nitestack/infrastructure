# Wake-on-LAN for nixstation

Wake-on-LAN (WoL) lets an already powered-down or sleeping computer start when its network interface receives a **magic packet** addressed to its Ethernet MAC address. Enabling an option in NixOS is only one part of the setup: the motherboard, network adapter, firmware, standby power, and network path must all cooperate.

This runbook targets `nixstation` (NixOS desktop) with `homestation` as the always-on sender.

```text
Remote device --Tailscale--> homestation --local Ethernet/LAN--> nixstation
                               (192.168.178.20)             (off/asleep)
```

Tailscale carries the *request* to homestation, not the WoL broadcast directly. The existing `192.168.178.0/24` subnet route is Layer 3 and does not forward Layer 2 broadcasts. The deployed UpSnap web UI on `homestation` provides the remote wake-up request; the hardware setup and local test below are still required.

## Prerequisites

- **Motherboard/firmware:** supports waking from the desired power state (suspend and/or full shutdown) via the onboard or add-in Ethernet controller.
- **Ethernet NIC and driver:** support magic-packet wake-up. Wired Ethernet is the intended path; Wake-on-WLAN is a separate, hardware-dependent feature.
- **Standby power:** PSU remains connected to mains and switched on; the NIC receives standby power while the PC is off. A disconnected power cable, switched-off PSU, or power strip cannot be overcome with WoL.
- **LAN:** nixstation is wired to the network, and an always-on sender (homestation) can reach its local broadcast domain. VLANs, wireless bridges, or client isolation can interfere.
- **Tailnet (for remote use):** homestation stays on, is reachable through Tailscale, and the calling device has permission to access it.

**Power states matter:** wake from suspend (typically S3) does not prove wake from hibernation (S4) or soft-off/shutdown (S5). Hardware can support only some states. “Restore on AC power loss” is a different feature, not WoL.

## 1. Identify the motherboard and Ethernet interface

On **nixstation**, identify the board so you can consult its actual manual:

```nu
cat /sys/class/dmi/id/board_vendor
cat /sys/class/dmi/id/board_name
```

Identify the active wired interface and connection profile:

```nu
ip -br link
nmcli device status
nmcli connection show --active
```

`enp8s0` appears as an example in the generated hardware configuration, **not** as a verified active interface. Substitute the actual Ethernet name in every command below. Do not use a Wi-Fi or Tailscale interface.

Read the active MAC address and the NIC's permanent hardware address (replace `enp8s0`):

```nu
cat /sys/class/net/enp8s0/address
nix shell nixpkgs#ethtool -c ethtool -P enp8s0
```

Prefer the permanent Ethernet MAC when registering the WoL target; NetworkManager can change the active address. If the driver does not report a permanent address, verify the correct hardware address with the NIC documentation.

Check driver support and current WoL state:

```nu
nix shell nixpkgs#ethtool -c ethtool enp8s0
```

Look for:

| Field | Meaning |
| --- | --- |
| `Supports Wake-on: ...g...` | Driver reports magic-packet support. |
| `Supports Wake-on: d` | No supported wake modes are reported; investigate NIC/driver/firmware. |
| `Wake-on: g` | Magic-packet wake-up is currently enabled. |
| `Wake-on: d` | Wake-up is currently disabled. |

`g` means magic packet; `d` means disabled. Even `Wake-on: g` does not guarantee the motherboard can wake from S5. If the command cannot query the interface, verify the device name and driver.

## 2. Enable motherboard firmware settings

Reboot **nixstation** and enter BIOS/UEFI (usually `Del` or `F2` during boot). Locate the power-management options in the **manual for the actual motherboard**; names and paths differ by manufacturer.

- Enable **Wake on LAN**, **Power On by PCI-E/PCI**, **Resume by PCIe Device**, or the equivalent setting for the Ethernet NIC.
- If present, disable **ErP/EuP** or **Deep Sx / Deep Sleep** when they cut standby power to the NIC, especially for wake from S5.
- If the board has separate options for **wake from S3/S4/S5** or **PME events**, enable the states you need.
- Save settings and boot normally. If firmware is outdated or an option is missing, consult the board/NIC manual before assuming support.

If the system dual-boots Windows, Windows Fast Startup (hybrid shutdown) may also affect wake after shutting down *from Windows*. Do not assume behavior after Windows shutdown matches behavior after NixOS shutdown.

## 3. Enable wake-up in NixOS and NetworkManager

On **nixstation**, set the NixOS option in `configurations/nixos/nixstation/default.nix`, using the *real* wired interface name:

```nix
networking.interfaces.enp8s0.wakeOnLan.enable = true;
```

Apply the normal host configuration from `~/infrastructure`:

```nu
cd ~/infrastructure
sudo nixos-rebuild switch --flake .#nixstation
```

**NetworkManager also manages the Ethernet device** in this repository (`modules/nixos/bare-metal-only.nix`). Its active profile can override the wake setting. Inspect the wired connection name with `nmcli connection show --active`, then configure **that profile**:

```nu
sudo nmcli connection modify "YOUR_WIRED_PROFILE" 802-3-ethernet.wake-on-lan magic
nmcli -g 802-3-ethernet.wake-on-lan connection show "YOUR_WIRED_PROFILE"
```

This `nmcli` modification persists in NetworkManager's connection profile, **but is not tracked by the flake**. For a fully declarative setup, manage an equivalent Ethernet profile through `networking.networkmanager.ensureProfiles`, taking care not to create competing profiles. Do not configure both approaches blindly.

Reboot nixstation and recheck `ethtool`. Verify `Wake-on: g` **after** NetworkManager activates the wired profile; a one-time `sudo ethtool -s enp8s0 wol g` is only useful for diagnosis, not persistent configuration.

## 4. Test locally from homestation

First test **suspend**, then **full shutdown**, because they exercise different power states.

1. On **nixstation**, record the wired NIC's MAC address from step 1. Suspend with `systemctl suspend`.
2. On **homestation**, send a packet to the LAN broadcast address (replace the example MAC):

   ```nu
   nix shell nixpkgs#wakeonlan -c wakeonlan -i 192.168.178.255 AA:BB:CC:DD:EE:FF
   ```

3. Confirm nixstation wakes. Then shut nixstation down with `sudo systemctl poweroff` and send the **same** packet again from homestation.
4. Re-test after another reboot/configuration deployment to ensure the setup is persistent.

`192.168.178.255` is the broadcast address for the configured `192.168.178.0/24` LAN. WoL targets the **Ethernet MAC**, not the sleeping machine's Tailscale IP. A successful `wakeonlan` command only confirms a packet was sent, not that the target accepted it.

**Do not open UDP port 9 on nixstation just for WoL.** A powered-off machine does not have a running NixOS firewall. The sender usually transmits a UDP magic packet to broadcast port 9; intermediate network equipment must permit it.

## 5. Wake from another tailnet device

[UpSnap](https://github.com/seriousm4x/UpSnap) runs on **homestation** as
`arion-upsnap.service`. It uses host networking to send WoL broadcasts on the
LAN, and its PocketBase user/device database lives in
`/var/lib/homelab/upsnap/data`. The service is configured in
[`upsnap.nix`](../configurations/nixos/homestation/homelab/upsnap.nix).

1. Deploy the committed configuration from `~/infrastructure` on **homestation**:

   ```nu
   cd ~/infrastructure
   sudo nixos-rebuild switch --flake .#homestation
   systemctl status arion-upsnap.service
   ```

2. Open **https://power.npham.de** from the LAN, or from a tailnet device using
   the same private DNS. Create UpSnap's first administrator account.
3. Add **nixstation** using its **permanent wired MAC address** (step 1),
   its LAN IPv4 address, and its subnet mask **`255.255.255.0`** (not
   `/24`). The device's IP is useful for status checks; the WoL packet
   targets its Ethernet MAC address. Test the Wake action while nixstation
   is suspended and again after a full shutdown.
4. Bookmark the HTTPS URL on a phone, tablet, or other tailnet client.
   UpSnap requires no client-side installation beyond a browser.

**Private access:** Caddy serves `power.npham.de` over local HTTPS, but
Cloudflare Tunnel does **not** expose the app. The UpSnap HTTP listener uses
homestation's LAN IP on port `8090`, with firewall access from Docker bridges
only. Do not forward that port to the internet. For remote clients, configure
the tailnet's DNS settings to resolve `npham.de` via **homestation's AdGuard
Home** (split DNS), and ensure they can reach `192.168.178.20` through the
approved Tailscale subnet route. Tailnet DNS and route approval are managed
outside this repository. Without those settings, a remote browser may hit
Cloudflare's public DNS/tunnel and receive a `403` rather than the private UI.

**Authentication:** Configure the UpSnap administrator immediately; give
other users only the device permissions they need. Custom shutdown commands
execute inside the container and should be avoided unless deliberately
configured and reviewed. UpSnap runs without root privileges and is restricted
to `NET_RAW` for network discovery/pings.

**Backup:** The existing Restic job stops the UpSnap service briefly while it
stages the PocketBase database, then restarts it. See
[Homestation backup and recovery](homestation-backup-recovery.md).

**Fallback CLI:** SSH to homestation over Tailscale and run the
`wakeonlan` command from step 4 if the dashboard is unavailable.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| No `g` in `Supports Wake-on` | Wrong interface, NIC/driver does not support magic packets, or firmware disabled the capability. Check the motherboard and NIC specifications. |
| `Wake-on: d` after reboot | NetworkManager profile may be overriding the NixOS setting; check the *active wired profile*, then retest after reconnect/reboot. |
| Wakes from suspend, not shutdown | Check whether firmware supports S5 wake; PCIe/PME wake, ErP, Deep Sx, and standby power are common causes. |
| Never wakes despite `Wake-on: g` | Verify the **Ethernet** MAC, cable, correct subnet broadcast, sender interface, and VLAN/client isolation. |
| Works locally, not from tailnet | Verify homestation is online, Tailscale's subnet route and split DNS are configured, and `power.npham.de` resolves to `192.168.178.20` rather than public Cloudflare ingress. |
| `power.npham.de` returns 502 | On homestation check `systemctl status arion-upsnap.service`, Docker logs, and whether Caddy can access the host's TCP/8090 through a Docker bridge. |
| Intermittent wake-up | Test with wired homestation and nixstation on the same VLAN; inspect NIC standby power and firmware behavior after shutdown. |

For packet-delivery debugging, run `tcpdump -ni <interface> 'udp port 9'` on **nixstation while it is awake**, and send the test packet from homestation. This verifies arrival while the OS runs; it does **not** prove that the NIC remains powered and armed after shutdown. Install `tcpdump` temporarily if needed.

## References

- [NixOS Wiki: Wake on LAN](https://wiki.nixos.org/wiki/Wake_on_LAN)
- [NetworkManager: Ethernet wake-on-lan profile setting](https://www.networkmanager.dev/docs/api/latest/nm-settings-nmcli.html)
- [ethtool manual: WoL modes](https://man7.org/linux/man-pages/man8/ethtool.8.html)
- [Tailscale: Wake-on-LAN through an always-on node](https://tailscale.com/blog/wake-on-lan-tailscale-upsnap)
- [UpSnap Docker deployment](https://github.com/seriousm4x/UpSnap/blob/master/docker-compose.yml)
- [Tailscale subnet routing](https://tailscale.com/kb/1019/subnets)
