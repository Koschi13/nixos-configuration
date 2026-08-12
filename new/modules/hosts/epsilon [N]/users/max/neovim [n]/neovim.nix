{
  flake.modules = {
    homeManager.neovim = {
      home = {
        file = {
          ".config/nvim/lua/plugins/blink-cmp-copilot.lua".source = ./astronvim/lua/plugins/blink-cmp-copilot.lua;
        };
      };
    };
  };
}
