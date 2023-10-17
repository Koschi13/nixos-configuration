# My NixOS configuration

## Props

https://github.com/Misterio77/nix-starter-configs/tree/main

## Using this repository

NOTE: `apply-user` is no longer working since I switched to flakes.
      Unfortunately I did not find out yet how to build it standalone.

Use the `apply-system` scripts to apply the configuration. E.g.:
```
./scripts/apply-system
```

This should use your hostname to generate the right config. If you don't have
the hostname set yet, you can use:
```
sudo nixos-rebuild switch --flake .#<hostname>
```
