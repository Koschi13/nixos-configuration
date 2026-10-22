{
  # Declares the CPU vendor of a host, so aspects can choose vendor specific
  # settings, like the kvm kernel module, without knowing the host.
  #
  # Hosts set it once, e.g. in their `hardware.nix`:
  #
  # ```nix
  # dotfiles.cpuVendor = "amd";
  # ```
  flake.modules.nixos.dotfiles-cpu = {lib, ...}: {
    # Deduplicates the module, see `dotfiles-users` in `lib/users [N]/users.nix`
    key = "dotfiles-cpu";

    options.dotfiles.cpuVendor = lib.mkOption {
      type = lib.types.enum ["amd" "intel"];
      description = "Vendor of the host's CPU.";
    };
  };
}
