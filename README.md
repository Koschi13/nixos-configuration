# My NixOS configuration


## Props

https://github.com/Misterio77/nix-starter-configs/tree/main

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

- [ ] Configure boot screen
- [ ] Set up Python via shells
- [ ] Install VS-Code. Either on a per-project basis or globally (maybe there are shell templates?)
- [x] Install PyCharm.  Either on a per-project basis or globally (maybe there are shell templates?)
- [x] Install Kubernetes and AWS-CLI
- [ ] Figure out, why the git config isn't working
- [x] Install Hyprland
- [x] Configure Hyprland
- [ ] Configure ZSH + Starship
- [x] Install Slack
- [ ] Configure AWS cli via HomeManager using the .secrets directory
- [ ] Configure VS-Code via HomeManager
