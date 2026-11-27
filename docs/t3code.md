# T3 Code

The Nitestack T3 Code fork is configured with Home Manager's native
`programs.t3code` module in `modules/home/ai.nix`; its package comes from the
`t3code` flake input rather than nixpkgs. Host mode is selected by profiles under
`configurations/home/`.

| Host | Mode |
| --- | --- |
| `nixstation` | Desktop app owns the local environment and T3 Connect route. |
| `homestation` | Headless `t3 serve --lan` user service (TCP port `3773` open on LAN and Tailscale). |
| `wslstation` | Headless `t3 serve` user service. |

The T3 Code package bundles its desktop executable and server CLI. `modules/home/ai.nix`
uses `t3code-full.override` from the `t3code` flake input, which provides
browser preview runtime libraries (via `NIX_LD_LIBRARY_PATH`, backed by
`programs.nix-ld.enable = true` in `modules/nixos/base.nix`), the local Android
emulator/device toolchain (`ANDROID_HOME`, `nodejs`, `ffmpeg`, JDK, and Android
SDK tools on `PATH`), `cloudflared` (via `T3CODE_CLOUDFLARED_PATH`), and
enables Codex, Claude Code, OpenCode, `git`, `gh`, `glab`, and
`antigravity-acp` on `PATH`. On the headless-only profiles, Home Manager is
given a small package wrapper that exposes only the `t3` launcher, so no T3
Code desktop launcher is added to those user profiles. The wrapper still
references the upstream combined package in the Nix store.

The source build needs T3 Connect's public build-time configuration or the app
hides its cloud controls and CLI support. `modules/home/ai.nix` copies
`.env.example` into the fork package's build environment to enable them; it
contains public identifiers, not credentials. The fork adds native aix
support; see the [fork repository](https://github.com/get-aix/aix-code) and its
[Nix installation guide](https://github.com/get-aix/aix-code/blob/main/docs/user/install.md).
The package sets `T3CODE_AIX=1` for its desktop and server launchers, using the
aix profiles already configured in Home Manager.

On `homestation` and `wslstation`, the server is a Home Manager user unit named
`t3code.service`, managed declaratively by each profile. `homestation` passes
`--lan` in `configurations/home/server.nix` and opens TCP port `3773` in
`configurations/nixos/homestation/default.nix` so paired and T3 Connect clients
can use direct LAN and Tailscale routes. User lingering is
enabled on both hosts, so the unit can run after logout and start when the
user manager starts. On `wslstation`, this does not start a stopped WSL distro:
Windows must be running and the distro must have started. Check either service
with:

```sh
systemctl --user status t3code.service
journalctl --user -u t3code.service -f
```

## Remote access with T3 Connect

Use T3 Connect for all three environments. It creates an outbound connection,
so this setup needs no router port forwarding, firewall port, or Tailscale node
on `wslstation`. Remote access is **not active** until each host is authorized
below. The T3 Connect account limit is three machines on the free plan; these
three hosts use all three slots. Phones and browsers do not count as machines.
This is privileged remote access to your environments, so protect the T3
account and the devices signed in to it.

### `nixstation` desktop

Keep **Local environment** enabled. In T3 Code on `nixstation`, open
**Settings → Sharing & access**, sign in to T3 Connect, and enable T3 Connect
for the local environment. The desktop app owns this environment, so the
Home Manager server is disabled for the desktop profile. Keep T3 Code running
while you need remote access; closing its last window stops its local server.

### Headless hosts

On `homestation` and `wslstation`, open a terminal as your regular user and run:

```sh
t3 connect link --headless
```

Run it on each headless host. If prompted, approve installation of T3's relay
client. Open the verification link it prints on a device with a browser, sign
in to the same T3 Connect account you will use on your phone, and approve the
displayed code. Treat the link and code like a password. This writes runtime
authorization under the user's T3 data directory; do not put it in Nix
configuration or share it.

After approving each host, restart its managed server and verify the link:

```sh
systemctl --user restart t3code.service
t3 connect status
```

Restarting stops any agent turns currently running on that host. `t3 connect
link` configures the next server start; keep Home Manager as the owner of
`t3code.service`. Do **not** run `t3 up` or `t3 service install`, which set up
T3's separate background-service manager.

Once all three hosts have T3 Connect enabled, sign in to the same account in T3
Code on the phone or Windows desktop. Open **Settings → Environments** and
select the host. T3 Connect does not require scanning a pairing QR code.

To check service health on `homestation` or `wslstation`, use
`systemctl --user status t3code.service` and
`journalctl --user -u t3code.service -f`. To disable T3 Connect on a headless
host, run `t3 connect unlink` as the same user; on `nixstation`, turn it off in
**Settings → Sharing & access**. See the
[T3 Code remote-access guide](https://github.com/get-aix/aix-code/blob/main/docs/user/remote-access.md)
and [Home Manager's native module](https://github.com/nix-community/home-manager/blob/master/modules/programs/t3code.nix)
for details.

The `wslstation` service is intentionally independent of any WSL backend that
Windows T3 Code may provision. It provides its own environment to remote
clients, including the phone app.

Provider authentication remains user-managed on each host. Do not put provider
credentials in Nix configuration; authenticate the installed CLI as the user
that runs T3 Code.
