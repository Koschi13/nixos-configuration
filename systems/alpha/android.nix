{pkgs, ...}: {
  environment.systemPackages = with pkgs; [android-tools];

  users.users.max.extraGroups = ["adbusers"];
}
