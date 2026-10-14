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
    options.dotfiles.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Names of the human users on this host.";
    };
  };
}
