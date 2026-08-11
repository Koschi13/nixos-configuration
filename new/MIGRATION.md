# Dropped on purpose

- `networking.networkmanager.plugins = [pkgs.networkmanager-openvpn]` -> Not used anymore
- `programs.dconf` -> Never used
- `services.pipewire.wireplumber` -> Never used
- `environment.pathsToLink = ["/libexec"]` -> I don't know what this was for
- `gaming` aspect only needed on `alpha`
- `stateVersion` was updated on purpose
- `xdg.portal.xonfig.common.default` is now `gtk` as this is the desired value
- `hardware.cpu.*.updateMicrocode` changed on purpose, the TODOs mark for later comparison against the original results
- `nixPath` changes was done on purpose as the original snippet didn't work
- `networking.useDHCP` is true by default and therfore omitted from now on
