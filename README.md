# My NixOS configuration

## Development

### Formatting

```shell
nixfmt .
```

## Using this repository

### Initial install

For the initial install you can use `./scripts/init-new-system.sh` which will
set up your disks. **Handle with care, this will automatically overwrite your
disk!**

After that run:

```
sudo nixos-install --flake .#<hostname>
```

### Setting up your system

Use the `apply-system` scripts to apply the configuration. E.g.:

```
./scripts/apply-system
```

This should use your hostname to generate the right config. If you don't have
the hostname set yet, you can use:

```
sudo nixos-rebuild switch --flake .#<hostname>
```

### Setting up your user

Use the `apply-user-<username>` scripts to apply the configuration. E.g.:

```
./scripts/apply-user-max.sh
```

## TODO

- [ ] Add dnd shortcut
- [ ] See if it is possible to save JetBrains settings in this repo, while still being able to change something via the UI
- [ ] Dunstctl window in the middle of the screen, E-Mails and Messages should appear longer (maybe with sound even?)
- [ ] Configure https://github.com/denisidoro/navi
- [ ] Create a windows like desktop as alternative (and maybe for gaming and office stuff)
- [ ] Define `~/.config/rofi/powermenu/type-3/powermenu.sh` (waybar)
- [ ] Define `rofi2` (waybar)
