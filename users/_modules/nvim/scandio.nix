{
  rootPath,
  lib,
  pkgs,
  ...
}: let
  vars = import "${rootPath}/.secrets/git_vars.nix";
  octoTemplate = builtins.readFile ./astronvim_scandio/templated/lua/plugins/octo-nvim.lua;
  octoConfig = builtins.replaceStrings ["<githubAlias>"] [vars.bshGit.host] octoTemplate;

  patchedCommunityLua = import ./astronvim_scandio/lua/community.nix {inherit pkgs;};
in {
  imports = [
    ./default.nix
  ];
  home = {
    file = {
      ".config/nvim/lua/community.lua" = lib.mkForce {
        source = "${patchedCommunityLua}/community.lua";
        force = true;
      };
      ".config/nvim/lua/plugins/copilot.lua".source = ./astronvim_scandio/lua/plugins/copilot.lua;
      ".config/nvim/lua/plugins/octo-nvim.lua".text = octoConfig;
    };
  };
}
