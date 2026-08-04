# luks

Produces a `nixos.<host>` configuration.

## Description

This configures `luks` to be available during boot, as well as what device
(by disk `uuid`) has to be decrypted before booting. You have to configure
your bootloader choice accordingly. For example for `grub` you need at least:
```nix
boot.loader.grub = {
  enable = true;
  device = "nodev";  # <-- This is important
};
```
## Usage

The desired way of using it is in the `hosts/<host>/configuration.nix` file,
where you have to call:
```nix
{
  self,
  inputs,
  lib,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.luks "<host>" "<device-id>")
    {
      nixos.alpha = {
        imports = with inputs.self.modules.nixos; [
          # ...modules
        ];
      };
    }
  ];
}
```
