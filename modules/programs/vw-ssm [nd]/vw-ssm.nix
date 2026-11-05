{
  # SSH access to the VW AWS hosts through the SSM session manager
  flake.modules.homeManager.vw-ssm = {
    osConfig,
    pkgs,
    ...
  }: {
    # The `Host` blocks of the VW hosts, decrypted by agenix (see the host
    # importing this aspect, e.g. `hosts/epsilon [N]/users/max.nix`)
    programs.ssh.includes = [osConfig.age.secrets.vw-ssh-config.path];

    home.packages = with pkgs; [
      awscli2
      ssm-session-manager-plugin # needed for SSM

      kubernetes
      eksctl

      sshuttle
    ];
  };
}
