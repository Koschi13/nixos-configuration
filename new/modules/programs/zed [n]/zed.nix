{
  flake.modules.homeManager.zed = {pkgs, ...}: {
    programs.zed-editor = {
      enable = true;
      # Required by the agent sandbox
      extraPackages = with pkgs; [bubblewrap];
    };
  };
}
