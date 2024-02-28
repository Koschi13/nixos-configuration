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

- [ ] Set up Python via shells
- [ ] Install VS-Code. Either on a per-project basis or globally (maybe there are shell templates?)
- [ ] Figure out, why the git config isn't working
- [ ] Configure AWS cli via HomeManager using the .secrets directory
- [ ] Add dnd shortcut
- [ ] Install and use a formatter: https://www.reddit.com/r/NixOS/comments/1acemjr/overview_of_nix_formatters_ecosystem
- [ ] `bd` not working
- [ ] Caps <-> Ctrl only for notebook
- [ ] See if it is possible to save JetBrains settings in this repo, while still being able to change something via the UI
- [ ] Use docker, since podman is making problems
- [ ] Git config `rerere.enabled true`
- [ ] Git config `branch.sort -committerdate`
- [ ] Git config `core.fsmonitor true`
- [ ] Git config `core.untrackedCache true`
