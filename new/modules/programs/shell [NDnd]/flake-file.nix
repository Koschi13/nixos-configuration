{
  flake-file.inputs = {
    # Catppuccin colorscheme for starship
    catppuccinStarship = {
      url = "github:catppuccin/starship";
      flake = false;
    };

    # ZSH plugins which are not in nixpkgs
    zsh-calc = {
      url = "github:arzzen/calc.plugin.zsh";
      flake = false;
    };
    zsh-enhancd = {
      url = "github:babarot/enhancd";
      flake = false;
    };
    zsh-alias-finder = {
      url = "github:akash329d/zsh-alias-finder";
      flake = false;
    };
  };
}
