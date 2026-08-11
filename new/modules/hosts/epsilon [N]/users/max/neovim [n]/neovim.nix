{
  flake.modules = {
    homeManager.epsilon = {
      home = {
        file = {
          ".config/nvim/lua/plugins/blink-cmp-copilot.lua".source = ./astronvim/lua/plugins/blink-cmp-copilot.lua;
        };
      };
    };
  };
}
