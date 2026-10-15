{inputs, ...}: {
  # SSH access to the VW AWS hosts through the SSM session manager
  flake.modules.homeManager.vw-ssm = {
    pkgs,
    lib,
    ...
  }: let
    vars = import "${inputs.git-crypt-secrets}/ssm_vw_vars.nix";

    # Every host of every region, with the proxy command of its region
    hosts = lib.concatMap (region: let
      startSession = "aws ssm start-session --region ${region.region} --profile ${vars.profile} --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'";
      proxyCommand = "sh -c \"${startSession}\"";
    in
      map (host: host // {inherit proxyCommand;}) region.hosts)
    vars.regions;

    sshHost = host: {
      inherit (host) hostname identityFile proxyCommand;
      inherit (vars) user;
    };

    # `<host>` connects to the host itself, `<host>_<service>` additionally
    # forwards the service to localhost.
    hostSettings = map (host: lib.nameValuePair host.name (sshHost host)) hosts;
    serviceSettings = lib.concatMap (host:
      map (service:
        lib.nameValuePair "${host.name}_${service.name}" (sshHost host
          // {
            localForward = ["${service.bind_port} ${service.host_address}:${service.host_port}"];
          }))
      host.services)
    hosts;

    # MY-HOST=<hostname> for scripts that need to address a host directly
    toEnvName = name: lib.toUpper (builtins.replaceStrings ["-"] ["_"] name);
  in {
    programs.ssh.settings = builtins.listToAttrs (hostSettings ++ serviceSettings);

    home = {
      packages = with pkgs; [
        awscli2
        ssm-session-manager-plugin # needed for SSM

        kubernetes
        eksctl

        sshuttle
      ];
      sessionVariables = builtins.listToAttrs (map (host: lib.nameValuePair (toEnvName host.name) host.hostname) hosts);
    };
  };
}
