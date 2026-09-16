{
  pkgs,
  rootPath,
  lib,
  ...
}: let
  vars = import "${rootPath}/.secrets/ssm_vw_vars.nix";

  # list[list[{host; service;}]]
  regions = map (config: let
    regionProfile = "--region ${config.region} --profile ${vars.profile}";
    startSessionCommand = "aws ssm start-session ${regionProfile} --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'";
    proxyCommand = "sh -c \"${startSessionCommand}\"";
  in
    map (host: {
      # list
      host = {
        name = host.name;
        value = {
          hostname = host.hostname;
          user = vars.user;
          identityFile = host.identityFile;
          proxyCommand = proxyCommand;
        };
      };

      # list[set]
      services =
        map (service: {
          name = "${host.name}_${service.name}";
          value = {
            hostname = host.hostname;
            user = vars.user;
            identityFile = host.identityFile;
            localForward = [
              "${service.bind_port} ${service.host_address}:${service.host_port}"
            ];
            proxyCommand = proxyCommand;
          };
        })
        host.services;
    })
    config.hosts)
  vars.regions;

  hostAttrs = builtins.listToAttrs (builtins.concatLists (map (regionConfigs: map (config: config.host) regionConfigs) regions));
  serviceAttrs = builtins.listToAttrs (builtins.concatLists (map (regionConfigs: builtins.concatLists (map (config: config.services) regionConfigs)) regions));
in {
  programs.ssh = {
    settings = hostAttrs // serviceAttrs;
  };

  home = {
    packages = with pkgs; [
      awscli2
      ssm-session-manager-plugin # needed for SSM

      kubernetes
      eksctl

      sshuttle
    ];
    sessionVariables = builtins.listToAttrs (builtins.concatLists (map (config:
      map (host: {
        name = lib.toUpper (builtins.replaceStrings ["-"] ["_"] host.name);
        value = host.hostname;
      })
      config.hosts)
    vars.regions));
  };
}
