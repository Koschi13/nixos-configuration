{
  # Collects what the backup of a host contains, so every aspect with state
  # declares its own part and the `backup` aspect only decides where and how
  # it's stored. An aspect adds its paths, and the units that prepare them,
  # only when the host imports `backup`:
  #
  # ```nix
  # imports = [self.modules.nixos.dotfiles-backup];
  # dotfiles.backup = lib.mkIf config.dotfiles.backup.enable {
  #   paths = ["/var/lib/<name>"];
  #   requiredServices = ["<name>-dump.service"];
  # };
  # ```
  flake.modules.nixos.dotfiles-backup = {lib, ...}: {
    # Several aspects import this module. The key lets the module system
    # deduplicate it, see `lib/users [N]/users.nix`.
    key = "dotfiles-backup";

    options.dotfiles.backup = {
      enable = lib.mkEnableOption "the backup of this host, set by the `backup` aspect";

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Paths the backup includes.";
      };

      requiredServices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          Units that run right before every backup and have to succeed, e.g.
          database dumps. The backup fails without them, instead of saving a
          stale state.
        '';
      };
    };
  };
}
