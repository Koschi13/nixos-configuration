{self, ...}: {
  # Virtual machines through libvirt, for all users of a host
  flake.modules.nixos.virtualisation = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.nixos.dotfiles-users];

    programs.virt-manager.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";

      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    # The kvm module depends on the CPU vendor, which hosts already declare
    # through their microcode settings.
    boot.kernelModules =
      lib.optional config.hardware.cpu.amd.updateMicrocode "kvm-amd"
      ++ lib.optional config.hardware.cpu.intel.updateMicrocode "kvm-intel";

    users.users = lib.genAttrs config.dotfiles.users (_: {
      extraGroups = ["kvm" "libvirtd"];
    });
  };
}
