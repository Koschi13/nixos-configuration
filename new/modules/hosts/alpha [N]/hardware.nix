{inputs, ...}: {
  flake.modules.nixos.alpha = {
    # No profile exists for this custom desktop, so it combines the generic
    # ones. They enable microcode updates, amd-pstate, the amdgpu driver in the
    # initrd, 32-bit graphics drivers for Wine and older games, and fstrim.
    imports = with inputs.nixos-hardware.nixosModules; [
      common-pc
      common-pc-ssd
      common-cpu-amd-pstate
      common-gpu-amd
    ];

    dotfiles.cpuVendor = "amd";
  };
}
