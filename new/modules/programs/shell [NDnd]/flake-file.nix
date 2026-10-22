{
  flake-file.inputs = {
    # ZSH plugins which are not in nixpkgs
    zsh-calc = {
      url = "github:arzzen/calc.plugin.zsh";
      flake = false;
    };

    zsh-alias-finder = {
      url = "github:akash329d/zsh-alias-finder";
      flake = false;
    };
  };
}
