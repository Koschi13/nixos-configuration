{inputs, ...}: {
  flake.modules.homeManager.mistral-vibe = {pkgs, ...}: {
    home.packages = [inputs.mistral-vibe.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };
}
