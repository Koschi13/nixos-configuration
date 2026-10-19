{self, ...}: {
  # Virtual machines through libvirt, for all users of a host
  flake.modules.nixos.virtualisation = {
    config,
    pkgs,
    ...
  }: {
    imports = with self.modules.nixos; [dotfiles-users dotfiles-cpu];

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

    boot.kernelModules = ["kvm-${config.dotfiles.cpuVendor}"];

    dotfiles.userGroups = ["kvm" "libvirtd"];
  };
}
