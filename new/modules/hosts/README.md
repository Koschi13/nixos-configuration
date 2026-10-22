# hosts

Contains the individual configurations per host.

This is basically the main entrypoint for the flake on each system, which
defines what packages and configurations each host has as well as the users
which are active on that host.
The users itself then have individual configurations you can find in
`modules/users`.

Each host directory contains:

- `default.nix`: creates the configuration via `self.lib.mkNixos`, which is
  the only place setting `nixpkgs.hostPlatform`.
- `configuration.nix`: the imported aspects and the host factory (`luks`).
- `hardware.nix`, `boot.nix`, `filesystem.nix`, `displays.nix`: the hardware
  of the host, including `dotfiles.cpuVendor`.
- `users/<user>.nix`: the users of the host and their host specific
  Home-Manager configuration, e.g. SSH match blocks.

> [!IMPORTANT]
> You have to import at least `system-default` or any higher level system
> configuration. Otherwise, the fundamentals of the flake setup will be
> missing.

> [!IMPORTANT]
> Set `dotfiles.cpuVendor` on every host. It has no default, so aspects
> reading it, like `virtualisation`, fail to evaluate without it.
