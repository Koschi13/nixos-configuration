{
  # SSH access to the VW AWS hosts through the SSM session manager
  flake.modules.homeManager.vw-ssm = {
    osConfig,
    pkgs,
    ...
  }: {
    # The `Host` blocks of the VW hosts, the `vw-ssh-config` secret of
    # `secrets/README.md`, declared by the host importing this aspect
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
