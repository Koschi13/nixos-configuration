# My Nix(OS) Configuration

## Usage

### Initial install

`./scripts/init-new-system-old.sh <disk-id>` partitions the disk and sets up
LUKS. **Handle with care, this wipes the disk!** It hasn't been validated
against the current configuration yet and exits early until it is.

After that, add the host to the configuration and install it, see
[Adding a host](#adding-a-host).

### Adding a host

1. Create `modules/hosts/<host> [N]/`, e.g. by copying `epsilon [N]`, and
   adapt it, see `modules/hosts/README.md`. Take the hardware of
   `nixos-generate-config --show-hardware-config` into `hardware.nix`,
   `boot.nix` and `filesystem.nix`.
2. `git add` the new files. Flakes only see files tracked by git.
3. Create the SSH host key that agenix decrypts the secrets with. openssh
   is only enabled by `system-cli` and starts after the secrets are decrypted,
   so nothing creates it in time. On a fresh install, before `nixos-install`:

   ```sh
   sudo mkdir -p /mnt/etc/ssh
   sudo ssh-keygen -q -t ed25519 -N "" -C root@<host> \
     -f /mnt/etc/ssh/ssh_host_ed25519_key
   ```

   On an installed host, use `/etc/ssh/ssh_host_ed25519_key` (create it the
   same way if it's missing).
4. Add the public key (`cat …/ssh_host_ed25519_key.pub`, without the comment)
   to `secrets/agenix-rules.nix` and run `scripts/secret-edit.sh -r`. This
   needs the YubiKey, so it's easiest on an existing host. Commit, push and
   pull on the new host.
5. Install (`sudo nixos-install --flake .#<host>`) or switch
   (`./scripts/apply.sh`). `sudo ls /run/agenix` lists the secrets.

The host key is the host's access to the secrets. Never commit it, and don't
back it up: a lost host gets a new key and steps 3 and 4 again. See the
Secrets section of `WIKI.md`.

### Applying the configuration

```sh
./scripts/apply.sh # runs `nh os switch .#`
```

This picks the configuration matching your hostname. Home-Manager runs as a
NixOS module, so the users are applied together with the system. Without `nh`,
or if the hostname isn't set yet, use:

```sh
sudo nixos-rebuild switch --flake .#<hostname>
```

### Deploying to a remote host

```sh
./scripts/deploy.sh <host> # runs `nh os switch` with `--target-host`
```

This host evaluates and builds the configuration, copies it over SSH and
activates it on `<host>.lan` as root. The `ssh` aspect only lets root log in
with the key of the YubiKey and from the trusted networks (`trustedNetworks`
in `modules/programs/ssh [Nnd]/ssh.nix`), so each deploy needs a touch. `sudo`
as `max` keeps asking for the password.

For changes that could lock you out (network, sshd, firewall), activate without
making the generation the boot default, so a reboot reverts it:

```sh
nh os test . --hostname <host> --target-host "root@<host>.lan" --elevation-strategy none
```

### Web services on a server

Each web service is reachable by name on port 80, e.g. `http://glance.lan`.
nginx (the `reverse-proxy` aspect) picks the service by name, and the services
themselves only listen on localhost. Every name needs a local DNS record on
the gateway pointing at the IP of the server:

| Name | Service |
|---|---|
| `glance.lan` | Glance |
| `firefly.lan` | Firefly III |
| `pgadmin.lan` | pgAdmin |

A new service adds its virtual host to `services.nginx.virtualHosts`, see
`modules/services/reverse-proxy [N]/reverse-proxy.nix`.

### Using the YubiKey on a remote host

`ssh fabricator` (or `fabricator.lan`) from `alpha` logs in as `max` and
forwards both gpg-agent sockets, so the YubiKey plugged into `alpha` works on
the server: SSH to git remotes, signed commits and `scripts/secret-edit.sh`.
The PIN prompt appears on `alpha`.

The newest forwarding session owns the sockets. Closing it breaks GPG and SSH
in older sessions until they reconnect. `ssh root@fabricator.lan` connects
without the forwards, which is what deploys use.

### Updating

```sh
./scripts/update.sh # runs `nix flake update`
```

### Formatting

```sh
nix fmt
```

`nix develop` (or direnv) installs the git hooks, which run `treefmt`,
`gitleaks` and `secrets-guard` before each commit.

### Cheats

`.cheats/` holds [navi](https://github.com/denisidoro/navi) cheats for the
commands of this repository, including the scripts above. Open navi with
`<C-g>` or `navi`.

navi doesn't pick up cheats from the current directory. It reads the paths in
`NAVI_PATH`, which `programs/navi` sets to the global cheats. With direnv,
`.envrc` appends `.cheats/` to it, so the repository cheats are only available
inside the repository. Without direnv, extend it yourself:

```sh
export NAVI_PATH="$NAVI_PATH:$HOME/.dotfiles/.cheats"
```

Or pass the path for a single run:

```sh
navi --path "$HOME/.dotfiles/.cheats"
```

## Dendritic

Every `.nix` file below `modules/` is a [flake-parts](https://flake.parts/)
module, imported automatically by
[import-tree](https://github.com/vic/import-tree). Files and directories
prefixed with `_` are ignored by import-tree.

- `hosts/<host>`: the entrypoint of each host, see `modules/hosts/README.md`
- `systems/`: layered base configurations (`system-default`, and on top of it
  either `system-desktop` or the headless `system-cli`)
- `users/<user>`: configuration per user, see `modules/users/README.md`
- `services/`, `programs/`: the aspects hosts and users pick from
- `lib/`: helpers (`mkNixos`, `mkDarwin`), factories and shared options

Hosts import systems and services, users import programs.

### Directory tags

Aspect directories carry a tag listing the classes they configure, so the
supported platforms are visible without opening the files:

| Tag | Class                            |
| --- | -------------------------------- |
| `N` | `nixos`                          |
| `D` | `darwin`                         |
| `n` | `homeManager` on Linux           |
| `d` | `homeManager` on macOS           |

For example `shell [NDnd]` configures every class, while `rofi [n]` only
exists for Home-Manager on Linux. `[]` marks flake-parts only modules.

A tag lists the classes that work, not just the ones that are written. A
`homeManager` aspect installing Linux-only packages, like `ghostty`, is
tagged `[n]` only. A system importing such an aspect loses the tag as well.

Only directories that are aspects get a tag. Nested directories holding
files for their parent aspect, like `neovim [Nn]/astronvim`, are covered by
the parent's tag. Nested aspects, like `neovim [Nn]/copilot [nd]`, carry
their own.

### Cross-cutting features

A file may contribute to aspects it doesn't own when it describes one
decision that touches several programs. `font.nix` sets the font of
`alacritty`, `ghostty` and `dunst`, and `terminal.nix` tells `rofi` and
`sway` which terminal to open. Changing the font or terminal then stays a one
file change, and the program aspects stay free of that choice.

### Shared options

Aspects must not know the host they are imported by. When they need host
facts, or a value shared by several programs, it is declared through a
`dotfiles.*` option:

- `dotfiles.users` / `dotfiles.userGroups` (`lib/users [N]`): the human users
  of a host, so aspects can add groups to all of them.
- `dotfiles.cpuVendor` (`lib/cpu [N]`): `"amd"` or `"intel"`, e.g. to select
  the kvm kernel module.
- `dotfiles.theme` (`lib/theme [nd]`): the active color theme, see
  [Themes](#themes).

These modules are imported by several aspects. As flake-parts wraps every
`self.modules.<class>.<name>` reference in a fresh anonymous module, the module
system can't deduplicate them by path. Aspects that must only be evaluated once
set a `key`, e.g. `key = "dotfiles-users";`, which the module system uses
instead. The same applies to aspects whose list options would otherwise be
duplicated, like `graphics` and `gnome-keyring`.

### Themes

`lib/theme [nd]` declares which theme is active (`dotfiles.theme`). The
theming itself is left to external projects that work with any theme family:

| Layer | Source | Used for |
| --- | --- | --- |
| Palette | [tinted-theming/schemes](https://github.com/tinted-theming/schemes) (`tinted-schemes` input) | every theme is a base24 (or base16) scheme |
| Theming | [stylix](https://github.com/nix-community/stylix), `stylix` aspect | every program with a stylix target |
| Own code | this repository | the selection, switching and what stylix doesn't cover (rofi's layout, neovim, VSCode) |

The `stylix` aspect enables no target by default. Each program imports it and
enables its target in its own file:

```nix
flake.modules.homeManager.dunst = {
  imports = [self.modules.homeManager.stylix];
  stylix.targets.dunst = {
    enable = true;
    fonts.enable = false; # fonts come from `font.nix`
  };
};
```

Programs referencing colors in their own configuration, like `waybar`'s
`style.css` or the `starship` prompt, only use the neutral names of the scheme
(`@base0D`, `base11`, `orange`), so they keep working with any theme. base24
schemes add `base10` to `base17` (e.g. darker backgrounds and bright colors);
for base16 schemes stylix falls back to the closest base16 color.

A theme is a scheme, its polarity and its name in programs shipping it
themselves (`integrations`, e.g. `nvim`). To add one, add a file to
`lib/theme [nd]`, like `catppuccin.nix`, and pick it in a variant:

```nix
{inputs, ...}: {
  flake.themes.gruvbox-dark = {
    scheme = "${inputs.tinted-schemes}/base24/gruvbox-dark.yaml";
    polarity = "dark";
  };
}
```

#### Variants

A variant is a named theme to switch to, `dotfiles.theme.variants` lists them:

```nix
dotfiles.theme = {
  variants = {
    dark = "catppuccin-frappe";
    light = "catppuccin-latte";
    dim = "gruvbox-dark"; # adding a variant is one line
  };
  default = "dark";
};
```

`theme toggle` (or `$mod+Shift+t` in sway) switches to the next variant
without a rebuild, `theme <variant>|status|list` sets, shows or lists them.
Every rebuild builds all variants, each one but the default as Home-Manager
specialisation, so switching only runs the already built activation and
reloads the running programs. `theme` reads the variants from the built
generation, so it knows none by name. The chosen variant is kept in
`~/.local/state/dotfiles/theme` and restored after rebuilds and logins.

Programs only care for the polarity of the active theme (dark or light
background), never for the name of the variant. Programs following the system
color scheme (Firefox, GTK apps, VSCode) switch through the `color-scheme`
that is published by the portal.

## Packages

- `pkgs.local.<name>`: packages maintained in `packages/`, see
  `modules/packages.nix`.
- `pkgs.stable.<name>`: the stable release, as escape hatch for packages broken
  on unstable. Its input follows `stateVersion.nixOs` in
  `systems/1 - default [NDn]/_stateVersion.nix`, so bumping the state version
  also bumps the stable release.

Both are overlays defined in `modules/packages.nix`. `mkNixos` and `mkDarwin`
apply them to every host, and `perSystem` gets them as well, so every module
can use them without importing anything.

## Flake inputs

`flake.nix` is generated by [flake-file](https://github.com/vic/flake-file)
and must not be edited by hand. Each aspect declares the inputs it needs in a
`flake-file.nix` next to it:

```nix
{
  flake-file.inputs.catppuccin-i3 = {
    url = "github:catppuccin/i3";
    flake = false;
  };
}
```

Regenerate `flake.nix` afterwards:

```sh
./scripts/flake-file.sh # runs `nix run .#write-flake`
```

## Docs

Functions are documented using the
[nixdoc](https://github.com/nix-community/nixdoc) syntax.

## Inspiration

- https://github.com/NotAShelf/nyx
- https://github.com/Doc-Steve/dendritic-design-with-flake-parts
- https://flake.parts/
