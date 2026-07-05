{...}: let
in {
  imports = [
    ./default.nix
  ];
  home = {
    file = {
      ".config/nvim/lua/plugins/blink-cmp-copilot.lua".source = ./astronvim_hiq/lua/plugins/blink-cmp-copilot.lua;
    };
  };
}
