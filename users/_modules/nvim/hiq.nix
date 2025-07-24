{rootPath, ...}: let
  vars = import "${rootPath}/.secrets/git_vars.nix";
  octoTemplate = builtins.readFile ./astronvim_hiq/templated/lua/plugins/octo-nvim.lua;
  octoConfig = builtins.replaceStrings ["<githubAlias>"] [vars.bshGit.host] octoTemplate;
in {
  imports = [
    ./default.nix
  ];
  home = {
    file = {
      ".config/nvim/lua/plugins/blink-cmp-copilot.lua".source = ./astronvim_hiq/lua/plugins/blink-cmp-copilot.lua;
      ".config/nvim/lua/plugins/octo-nvim.lua".text = octoConfig;
    };
  };
}
