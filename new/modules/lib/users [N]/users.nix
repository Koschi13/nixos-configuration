{
  # Collects the users of a host, so aspects can configure all of them alike
  # instead of being instantiated per user.
  #
  # Each user aspect adds itself, host aspects read the list:
  #
  # ```nix
  # users.users = lib.genAttrs config.dotfiles.users (_: {extraGroups = ["audio"];});
  # ```
  #
  # `config.users.users` can't be used for this, as aspects writing to it
  # while reading from it causes an infinite recursion.
  flake.modules.nixos.dotfiles-users = {lib, ...}: {
    # Several aspects import this module. The key lets the module system
    # deduplicate it, as flake-parts wraps every import in a fresh module.
    #
    # Normally the NixOS module system deduplicates imports by file path: if
    # the same file is imported ten times, it’s only evaluated once. But here’s
    # the catch with flake-parts: self.modules.nixos.dotfiles-users isn’t a
    # bare file path — flake-parts wraps the module in a fresh anonymous module
    # each time you reference it. So the module system sees ten different
    # anonymous modules that all happen to define options.dotfiles.users, and
    # it complains: “option defined multiple times” (an option can only be
    # declared once).
    key = "dotfiles-users";

    options.dotfiles.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Names of the human users on this host.";
    };
  };
}
