{
  # `nix fmt` inside `new/`, matching the formatter of the old flake
  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };
}
